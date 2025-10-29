package com.example.cleanlink

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.isVisible

class MainActivity : AppCompatActivity() {

    private lateinit var input: EditText
    private lateinit var cleanBtn: Button
    private lateinit var resetBtn: Button
    private lateinit var openBtn: Button
    private lateinit var shareBtn: Button

    private lateinit var twitterRow: LinearLayout
    private lateinit var vxRow: LinearLayout
    private lateinit var fxRow: LinearLayout
    private lateinit var genericRow: LinearLayout

    private lateinit var twitterText: TextView
    private lateinit var vxText: TextView
    private lateinit var fxText: TextView
    private lateinit var genericText: TextView

    private var lastResult: LinkCleaner.CleanResult? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        bindViews()
        setupButtons()
        handleIncomingShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIncomingShare(intent)
    }

    private fun bindViews() {
        input = findViewById(R.id.inputUrl)
        cleanBtn = findViewById(R.id.btnClean)
        resetBtn = findViewById(R.id.btnReset)
        openBtn = findViewById(R.id.btnOpen)
        shareBtn = findViewById(R.id.btnShare)

        twitterRow = findViewById(R.id.rowTwitter)
        vxRow = findViewById(R.id.rowVx)
        fxRow = findViewById(R.id.rowFx)
        genericRow = findViewById(R.id.rowGeneric)

        twitterText = findViewById(R.id.txtTwitter)
        vxText = findViewById(R.id.txtVx)
        fxText = findViewById(R.id.txtFx)
        genericText = findViewById(R.id.txtGeneric)

        listOf(twitterText to "Twitter", vxText to "VxTwitter", fxText to "FxTwitter", genericText to "Clean Link").forEach { (tv, label) ->
            tv.setOnClickListener { copyToClipboard(tv.text.toString(), label) }
        }
    }

    private fun setupButtons() {
        cleanBtn.setOnClickListener { cleanCurrent() }
        resetBtn.setOnClickListener { resetAll() }
        openBtn.setOnClickListener { openPreferred() }
        shareBtn.setOnClickListener { sharePreferred() }
    }

    private fun cleanCurrent() {
        val raw = input.text.toString()
        val result = LinkCleaner.clean(raw)
        if (result == null) {
            toast("Invalid or unsupported URL")
            return
        }
        lastResult = result
        updateOutput(result)
    }

    private fun updateOutput(result: LinkCleaner.CleanResult) {
        twitterText.text = result.twitter ?: ""
        vxText.text = result.vxTwitter ?: ""
        fxText.text = result.fxTwitter ?: ""
        genericText.text = result.generic ?: ""

        twitterRow.isVisible = result.twitter != null
        vxRow.isVisible = result.vxTwitter != null
        fxRow.isVisible = result.fxTwitter != null
        genericRow.isVisible = result.generic != null
    }

    private fun resetAll() {
        input.text.clear()
        lastResult = null
        listOf(twitterText, vxText, fxText, genericText).forEach { it.text = "" }
        listOf(twitterRow, vxRow, fxRow, genericRow).forEach { it.isVisible = false }
        toast("Reset")
    }

    private fun copyToClipboard(text: String, label: String) {
        if (text.isBlank()) return
        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        cm.setPrimaryClip(ClipData.newPlainText(label, text))
        toast("Copied $label")
    }

    private fun openPreferred() {
        val link = lastResult?.preferred ?: return toast("Nothing to open")
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
        // Prefer Chrome if available
        intent.`package` = "com.android.chrome"
        if (packageManager.resolveActivity(intent, 0) == null) {
            intent.`package` = null
        }
        startActivity(intent)
    }

    private fun sharePreferred() {
        val link = lastResult?.preferred ?: return toast("Nothing to share")
        val share = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, link)
        }
        startActivity(Intent.createChooser(share, "Share cleaned link"))
    }

    private fun handleIncomingShare(intent: Intent) {
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
            if (!sharedText.isNullOrBlank()) {
                input.setText(sharedText)
                cleanCurrent()
            }
        }
    }

    private fun toast(msg: String) = Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
}

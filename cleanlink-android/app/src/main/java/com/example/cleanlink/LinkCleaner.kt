package com.example.cleanlink

import java.net.URL

/** Cleans social/media URLs, providing alt frontends for X/Twitter when possible. */
object LinkCleaner {
    data class CleanResult(
        val original: String,
        val twitter: String? = null,
        val vxTwitter: String? = null,
        val fxTwitter: String? = null,
        val generic: String? = null
    ) {
        /** Preferred single link for sharing/opening (twitter primary else generic). */
        val preferred: String
            get() = twitter ?: generic ?: original
    }

    private val timeRegex = Regex("^[0-9]+([smh])?$")

    fun clean(raw: String): CleanResult? {
        val trimmed = raw.trim()
        if (trimmed.isEmpty()) return null
        val url = try { URL(extractUrlString(trimmed)) } catch (e: Exception) { return null }
        val host = url.host.lowercase().removePrefix("www.")

        // Twitter/X logic
        if (host == "x.com" || host == "twitter.com") {
            val statusPath = extractStatusPath(url.toString()) ?: return null
            val twitter = "https://x.com$statusPath"
            val vx = "https://vxtwitter.com$statusPath"
            val fx = "https://fxtwitter.com$statusPath"
            return CleanResult(original = trimmed, twitter = twitter, vxTwitter = vx, fxTwitter = fx, generic = twitter)
        }
        // Instagram: strip query
        if (host == "instagram.com") {
            val clean = "${url.protocol}://${url.host}${url.path}".removeSuffix("/")
            return CleanResult(original = trimmed, generic = clean)
        }
        // YouTube rules: preserve v id (video) and valid t; for youtu.be short links map path to v param
        if (host == "youtube.com" || host == "youtu.be") {
            var vVal: String? = null
            if (host == "youtu.be") {
                // youtu.be/<id> -> id before any further path segments
                val shortId = url.path.trim('/').split('/').firstOrNull()?.takeWhile { it.isLetterOrDigit() || it == '-' || it == '_' }
                if (!shortId.isNullOrEmpty()) vVal = shortId
            }
            val comps = url.query?.split('&') ?: emptyList()
            var tVal: String? = null
            for (p in comps) {
                val parts = p.split('=')
                if (parts.size == 2) {
                    when(parts[0]) {
                        "v" -> if (vVal == null) vVal = parts[1]
                        "t" -> if (timeRegex.matches(parts[1])) tVal = parts[1]
                    }
                }
            }
            val params = mutableListOf<String>()
            if (vVal != null) params += "v=$vVal"
            if (tVal != null) params += "t=$tVal"
            val suffix = if (params.isNotEmpty()) "?" + params.joinToString("&") else ""
            val clean = "${url.protocol}://${url.host}${url.path.takeWhile { it != '?' && it != '#' }}$suffix"
            return CleanResult(original = trimmed, generic = clean)
        }
        // Threads: strip query
        if (host == "threads.net" || host == "threads.com") {
            val clean = "${url.protocol}://${url.host}${url.path}".removeSuffix("/")
            return CleanResult(original = trimmed, generic = clean)
        }
        // Generic fallback: remove all query params
        val clean = "${url.protocol}://${url.host}${url.path}".removeSuffix("/")
        return CleanResult(original = trimmed, generic = clean)
    }

    /** Extract first URL-like token from raw share text (handles multiple lines). */
    private fun extractUrlString(input: String): String {
        val urlRegex = Regex("https?://[\n\r\t \u0000-\u007F]+", RegexOption.IGNORE_CASE)
        val match = urlRegex.find(input)
        return match?.value?.split(' ', '\n', '\r', '\t')?.firstOrNull { it.startsWith("http") } ?: input
    }

    private fun extractStatusPath(urlStr: String): String? {
        return try {
            val u = URL(urlStr)
            var host = u.host.lowercase()
            host = host.removePrefix("m.").removePrefix("mobile.")
            if (host != "twitter.com" && host != "x.com") return null
            val parts = u.path.split('/').filter { it.isNotBlank() }
            val statusIdx = parts.indexOfFirst { it.equals("status", ignoreCase = true) }
            if (statusIdx == -1 || statusIdx == parts.lastIndex) return null
            val id = parts[statusIdx + 1].takeWhile { it.isDigit() }
            if (id.isEmpty()) return null
            
            val user = parts.firstOrNull() ?: return null
            
            
            
            
            "./$user/status/$id".removePrefix("./").let { "/$user/status/$id" }
        } catch (e: Exception) { null }
    }
}

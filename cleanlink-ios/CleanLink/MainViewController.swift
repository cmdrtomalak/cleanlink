import UIKit
class MainViewController: UIViewController {
    private let inputField = UITextField(); private let cleanButton = UIButton(type: .system); private let resetButton = UIButton(type: .system); private let openButton = UIButton(type: .system); private let shareButton = UIButton(type: .system)
    private let twitterLabel = tappableLabel(); private let vxLabel = tappableLabel(); private let fxLabel = tappableLabel(); private let genericLabel = tappableLabel(); private var lastResult: CleanResult?
    override func viewDidLoad() { super.viewDidLoad(); title = "Clean Link"; view.backgroundColor = .systemBackground; setupUI() }
    func setIncomingSharedText(_ text: String) { inputField.text = text; cleanAction() }
    private func setupUI() {
        inputField.placeholder = "Paste URL or share into app"; inputField.borderStyle = .roundedRect; inputField.autocapitalizationType = .none; inputField.autocorrectionType = .no; inputField.keyboardType = .URL; inputField.addTarget(self, action: #selector(textReturn), for: .editingDidEndOnExit)
        cleanButton.setTitle("Clean", for: .normal); resetButton.setTitle("Reset", for: .normal); openButton.setTitle("Open", for: .normal); shareButton.setTitle("Share", for: .normal)
        cleanButton.addTarget(self, action: #selector(cleanTap), for: .touchUpInside); resetButton.addTarget(self, action: #selector(resetTap), for: .touchUpInside); openButton.addTarget(self, action: #selector(openTap), for: .touchUpInside); shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        let buttonsTop = UIStackView(arrangedSubviews: [cleanButton, resetButton]); buttonsTop.axis = .horizontal; buttonsTop.spacing = 12; buttonsTop.distribution = .fillEqually
        let buttonsBottom = UIStackView(arrangedSubviews: [openButton, shareButton]); buttonsBottom.axis = .horizontal; buttonsBottom.spacing = 12; buttonsBottom.distribution = .fillEqually
        let outputs = UIStackView(arrangedSubviews: [makeRow("Twitter (clean)", twitterLabel), makeRow("VxTwitter", vxLabel), makeRow("FxTwitter", fxLabel), makeRow("Clean Link", genericLabel)]); outputs.axis = .vertical; outputs.spacing = 14
        let rootStack = UIStackView(arrangedSubviews: [inputField, buttonsTop, buttonsBottom, outputs]); rootStack.axis = .vertical; rootStack.spacing = 16
        view.addSubview(rootStack); rootStack.translatesAutoresizingMaskIntoConstraints = false; inputField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        NSLayoutConstraint.activate([rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16), rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16), rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)])
        [twitterLabel, vxLabel, fxLabel, genericLabel].forEach { let tap = UITapGestureRecognizer(target: self, action: #selector(copyTap(_:))); $0.addGestureRecognizer(tap) }; hideAllOutputs() }
    private func makeRow(_ title: String, _ valueLabel: UILabel) -> UIStackView { let t = UILabel(); t.text = title; t.font = UIFont.boldSystemFont(ofSize: 15); let s = UIStackView(arrangedSubviews: [t, valueLabel]); s.axis = .vertical; s.spacing = 4; return s }
    private static func tappableLabel() -> UILabel { let l = UILabel(); l.text = ""; l.numberOfLines = 0; l.font = .systemFont(ofSize: 14); l.backgroundColor = UIColor(white: 0.95, alpha: 1); l.layer.cornerRadius = 6; l.clipsToBounds = true; l.isUserInteractionEnabled = true; l.textColor = UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 1.0); l.lineBreakMode = .byCharWrapping; return l }
    @objc private func textReturn() { cleanAction() }; @objc private func cleanTap() { cleanAction() }; @objc private func resetTap() { resetAction() }; @objc private func openTap() { openAction() }; @objc private func shareTap() { shareAction() }
    private func cleanAction() { guard let txt = inputField.text, let res = LinkCleaner.clean(txt) else { toast("Invalid / unsupported URL"); return }; lastResult = res; updateOutputs(res) }
    private func resetAction() { inputField.text = ""; lastResult = nil; hideAllOutputs(); toast("Reset") }
    private func openAction() { guard let link = lastResult?.preferred, let url = URL(string: link) else { toast("Nothing to open"); return }; UIApplication.shared.open(url, options: [:], completionHandler: nil) }
    private func shareAction() { guard let link = lastResult?.preferred else { toast("Nothing to share"); return }; let avc = UIActivityViewController(activityItems: [link], applicationActivities: nil); avc.popoverPresentationController?.sourceView = view; present(avc, animated: true) }
    private func updateOutputs(_ r: CleanResult) { twitterLabel.text = r.twitter; vxLabel.text = r.vxTwitter; fxLabel.text = r.fxTwitter; genericLabel.text = r.generic; twitterLabel.superview?.isHidden = r.twitter == nil; vxLabel.superview?.isHidden = r.vxTwitter == nil; fxLabel.superview?.isHidden = r.fxTwitter == nil; genericLabel.superview?.isHidden = r.generic == nil }
    private func hideAllOutputs() { [twitterLabel, vxLabel, fxLabel, genericLabel].forEach { $0.text = ""; $0.superview?.isHidden = true } }
    @objc private func copyTap(_ g: UITapGestureRecognizer) { guard let l = g.view as? UILabel, let t = l.text, !t.isEmpty else { return }; UIPasteboard.general.string = t; toast("Copied") }
    private func toast(_ msg: String) { let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert); present(a, animated: true); DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { a.dismiss(animated: true) } }
}

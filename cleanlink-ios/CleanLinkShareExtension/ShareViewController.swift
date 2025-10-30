//
//  ShareViewController.swift
//  CleanLinkShareExtension
//
//  Created by Kwai Liu on 10/29/25.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CleanLink"
        processIncoming()
    }

    private func processIncoming() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for item in items {
            if let providers = item.attachments {
                for provider in providers {
                    if provider.hasItemConformingToTypeIdentifier("public.url") {
                        provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (data, _) in
                            if let url = data as? URL { self.cleanAndSet(url.absoluteString) }
                        }
                        return
                    } else if provider.hasItemConformingToTypeIdentifier("public.text") {
                        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, _) in
                            if let text = data as? String { self.cleanAndSet(text) }
                        }
                        return
                    }
                }
            }
        }
        if !contentText.isEmpty { cleanAndSet(contentText) }
    }

    private func cleanAndSet(_ raw: String) {
        if let res = LinkCleaner.clean(raw) {
            DispatchQueue.main.async { self.textView.text = res.preferred }
        }
    }

    override func isContentValid() -> Bool { !contentText.isEmpty }

    override func didSelectPost() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! { return [] }
}

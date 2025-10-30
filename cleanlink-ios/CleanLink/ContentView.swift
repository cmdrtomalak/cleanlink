//
//  ContentView.swift
//  CleanLink-iOS
//
//  Created by Kwai Liu on 10/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var rawInput: String = ""
    @State private var result: CleanResult? = nil
    @State private var showShare: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Paste a URL or share into app", text: $rawInput)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                HStack {
                    Button("Clean") { clean() }.buttonStyle(.borderedProminent)
                    Button("Reset") { reset() }.buttonStyle(.bordered)
                }

                if let r = result { cleanedSection(r) }

                Spacer()

                if let _ = result {
                    HStack {
                        Button("Open Preferred") { openPreferred() }
                        Button("Share Preferred") { showShare = true }
                    }
                }
            }
            .padding()
            .navigationTitle("CleanLink")
            .sheet(isPresented: $showShare) {
                if let r = result { ActivityView(activityItems: [r.preferred]) }
            }
        }
    }

    @ViewBuilder private func cleanedSection(_ r: CleanResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let t = r.twitter { linkRow(label: "Twitter", value: t) }
            if let vx = r.vxTwitter { linkRow(label: "VxTwitter", value: vx) }
            if let fx = r.fxTwitter { linkRow(label: "FxTwitter", value: fx) }
            if let g = r.generic { linkRow(label: "Clean Link", value: g) }
        }
    }

    private func linkRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.caption).bold()
            Text(value)
                .font(.caption)
                .foregroundColor(.blue)
                .contextMenu { Button("Copy") { copy(value) } }
                .onTapGesture { copy(value) }
        }
    }

    private func clean() { result = LinkCleaner.clean(rawInput) }
    private func reset() { rawInput = ""; result = nil }
    private func copy(_ text: String) { UIPasteboard.general.string = text }
    private func openPreferred() {
        guard let urlStr = result?.preferred, let url = URL(string: urlStr) else { return }
        UIApplication.shared.open(url)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: activityItems, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview { ContentView() }

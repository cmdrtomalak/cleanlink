import Foundation
struct CleanResult { let original: String; let twitter: String?; let vxTwitter: String?; let fxTwitter: String?; let generic: String?; var preferred: String { twitter ?? generic ?? original } }
class LinkCleaner {
    static let timeRegex = try! NSRegularExpression(pattern: "^[0-9]+([smh])?$")
    static func clean(_ raw: String) -> CleanResult? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: extractUrlString(trimmed)) else { return nil }
        let host = (url.host ?? "").lowercased().replacingOccurrences(of: "www.", with: "")
        if host == "x.com" || host == "twitter.com" { guard let statusPath = extractStatusPath(url.absoluteString) else { return nil }; let tw = "https://x.com" + statusPath; let vx = "https://vxtwitter.com" + statusPath; let fx = "https://fxtwitter.com" + statusPath; return CleanResult(original: trimmed, twitter: tw, vxTwitter: vx, fxTwitter: fx, generic: tw) }
        if host == "instagram.com" { let clean = "\(url.scheme ?? "https")://\(url.host ?? "")\(url.path)".replacingOccurrences(of: "/$", with: "", options: .regularExpression); return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean) }
        if host == "youtube.com" || host == "youtu.be" {
            var vVal: String? = nil
            if host == "youtu.be" {
                let shortId = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).components(separatedBy: "/").first?.prefix { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
                if let sid = shortId, !sid.isEmpty { vVal = String(sid) }
            }
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let items = comps?.queryItems ?? []
            let tRaw = items.first(where: { $0.name == "t" })?.value
            let tVal = (tRaw != nil && matchesTime(tRaw!)) ? tRaw : nil
            if vVal == nil { vVal = items.first(where: { $0.name == "v" })?.value }
            var parts: [String] = []
            if let v = vVal { parts.append("v=\(v)") }
            if let t = tVal { parts.append("t=\(t)") }
            let suffix = parts.isEmpty ? "" : "?" + parts.joined(separator: "&")
            let basePath = url.path
            let clean = "\(url.scheme ?? "https")://\(url.host ?? "")\(basePath)\(suffix)"
            return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean)
        }
        if host == "threads.net" || host == "threads.com" { let clean = "\(url.scheme ?? "https")://\(url.host ?? "")\(url.path)".replacingOccurrences(of: "/$", with: "", options: .regularExpression); return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean) }
        let clean = "\(url.scheme ?? "https")://\(url.host ?? "")\(url.path)".replacingOccurrences(of: "/$", with: "", options: .regularExpression); return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean) }
    private static func matchesTime(_ v: String) -> Bool { let r = NSRange(location: 0, length: v.utf16.count); return timeRegex.firstMatch(in: v, range: r) != nil }
    private static func extractUrlString(_ input: String) -> String { if let range = input.range(of: "https?://", options: .regularExpression) { return String(input[range.lowerBound...]).components(separatedBy: CharacterSet.whitespacesAndNewlines).first ?? input }; return input }
    private static func extractStatusPath(_ s: String) -> String? { guard let u = URL(string: s), var host = u.host?.lowercased() else { return nil }; host = host.replacingOccurrences(of: "m.", with: "").replacingOccurrences(of: "mobile.", with: ""); guard host == "twitter.com" || host == "x.com" else { return nil }; let parts = u.path.split(separator: "/").map(String.init); guard let idx = parts.firstIndex(where: { $0.lowercased() == "status" }), idx < parts.count - 1 else { return nil }; let id = parts[idx+1].prefix { $0.isNumber }; guard !id.isEmpty, let user = parts.first else { return nil }; return "/\(user)/status/\(id)" }
}

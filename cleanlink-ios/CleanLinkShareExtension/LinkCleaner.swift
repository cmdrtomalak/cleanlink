import Foundation

struct CleanResult {
    let original: String
    let twitter: String?
    let vxTwitter: String?
    let fxTwitter: String?
    let generic: String?
    var preferred: String { twitter ?? generic ?? original }
}

enum LinkCleaner {
    private static let timeRegex = try! NSRegularExpression(pattern: "^[0-9]+([smh])?$", options: [])

    static func clean(_ raw: String) -> CleanResult? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let urlStr = extractUrlString(trimmed), let url = URL(string: urlStr) else { return nil }
        guard let host = url.host?.lowercased().replacingOccurrences(of: "www.", with: "") else { return nil }

        if host == "x.com" || host == "twitter.com" || host.hasSuffix(".twitter.com") {
            if let statusPath = extractStatusPath(url.absoluteString) {
                let twitter = "https://x.com" + statusPath
                let vx = "https://vxtwitter.com" + statusPath
                let fx = "https://fxtwitter.com" + statusPath
                return CleanResult(original: trimmed, twitter: twitter, vxTwitter: vx, fxTwitter: fx, generic: twitter)
            } else { return nil }
        }
        if host == "instagram.com" {
            let clean = (url.scheme ?? "https") + "://" + host + url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean)
        }
        if host == "youtube.com" || host == "youtu.be" {
            var vVal: String? = nil
            if host == "youtu.be" {
                let shortId = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).components(separatedBy: "/").first?.filter { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
                if let sid = shortId, !sid.isEmpty { vVal = sid }
            }
            var tVal: String? = nil
            if let query = url.query {
                for part in query.split(separator: "&") {
                    let kv = part.split(separator: "=")
                    if kv.count == 2 {
                        let key = String(kv[0])
                        let val = String(kv[1])
                        switch key {
                        case "v": if vVal == nil { vVal = val }
                        case "t": if timeRegex.matches(in: val, options: [], range: NSRange(location: 0, length: val.count)).count == 1 { tVal = val }
                        default: break
                        }
                    }
                }
            }
            var params: [String] = []
            if let vVal = vVal { params.append("v=\(vVal)") }
            if let tVal = tVal { params.append("t=\(tVal)") }
            let suffix = params.isEmpty ? "" : "?" + params.joined(separator: "&")
            let pathNoQuery = url.path.split(separator: "?").first.map(String.init) ?? url.path
            let clean = (url.scheme ?? "https") + "://" + (url.host ?? host) + pathNoQuery + suffix
            return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean)
        }
        if host == "threads.net" || host == "threads.com" {
            let clean = (url.scheme ?? "https") + "://" + host + url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean)
        }
        let clean = (url.scheme ?? "https") + "://" + host + url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return CleanResult(original: trimmed, twitter: nil, vxTwitter: nil, fxTwitter: nil, generic: clean)
    }

    private static func extractUrlString(_ input: String) -> String? {
        let pattern = "https?://[A-Za-z0-9./?=&_%:-]+"
        if let range = input.range(of: pattern, options: .regularExpression) {
            return String(input[range])
        }
        return input.starts(with: "http") ? input : nil
    }

    private static func extractStatusPath(_ urlStr: String) -> String? {
        guard let u = URL(string: urlStr), var host = u.host?.lowercased() else { return nil }
        host = host.replacingOccurrences(of: "m.", with: "").replacingOccurrences(of: "mobile.", with: "")
        guard host == "twitter.com" || host == "x.com" else { return nil }
        let parts = u.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
        guard let statusIdx = parts.firstIndex(where: { $0.lowercased() == "status" }), statusIdx < parts.count - 1 else { return nil }
        let id = parts[statusIdx + 1].prefix { $0.isNumber }
        guard !id.isEmpty else { return nil }
        guard let user = parts.first else { return nil }
        return "/\(user)/status/\(id)"
    }
}

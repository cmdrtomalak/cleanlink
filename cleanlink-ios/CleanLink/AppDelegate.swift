import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible(); return true }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard url.scheme == "cleanlink" else { return false }
        if let nav = window?.rootViewController as? UINavigationController, let vc = nav.viewControllers.first as? MainViewController, let comps = URLComponents(url: url, resolvingAgainstBaseURL: false), let uParam = comps.queryItems?.first(where: { $0.name == "u" })?.value { vc.setIncomingSharedText(uParam) }
        return true }
}

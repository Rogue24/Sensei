import Foundation

enum Settings {
    static var customHost: String {
        get {
            UserDefaults.standard.string(forKey: "customHost") ?? "api.openai.com"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "customHost")
        }
    }

    static var apiKey: String {
        get {
            UserDefaults.standard.string(forKey: "apiKey") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "apiKey")
        }
    }

    static var enterToSend: Bool {
        get {
            UserDefaults.standard.object(forKey: "enterToSend") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enterToSend")
        }
    }
}

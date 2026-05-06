import Foundation

final class AppConfigStore {
    static let shared = AppConfigStore()

    private enum Keys {
        static let baseURL = "ai_engine_base_url"
        static let selectedModel = "ai_engine_selected_model"
    }

    private let defaults: UserDefaults
    private let defaultBaseURLString = "https://api.deepseek.com/v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var baseURLString: String {
        get {
            let value = defaults.string(forKey: Keys.baseURL)?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (value?.isEmpty == false) ? value! : defaultBaseURLString
        }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                defaults.removeObject(forKey: Keys.baseURL)
            } else {
                defaults.set(trimmed, forKey: Keys.baseURL)
            }
        }
    }

    var baseURL: URL {
        URL(string: baseURLString) ?? URL(string: defaultBaseURLString)!
    }

    var selectedModel: String? {
        get {
            let value = defaults.string(forKey: Keys.selectedModel)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        set {
            let trimmed = newValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimmed.isEmpty {
                defaults.removeObject(forKey: Keys.selectedModel)
            } else {
                defaults.set(trimmed, forKey: Keys.selectedModel)
            }
        }
    }
}

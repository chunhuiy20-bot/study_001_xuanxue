import Foundation

struct AIEngineConfig {
    let baseURL: URL
    let apiKey: String
    let model: String?
}

enum AIConfigError: Error {
    case invalidBaseURL
    case missingAPIKey
}

enum AIConfigProvider {
    static func current() throws -> AIEngineConfig {
        let urlString = AppConfigStore.shared.baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let baseURL = URL(string: urlString), !urlString.isEmpty else {
            throw AIConfigError.invalidBaseURL
        }

        guard let apiKey = APIKeyStore.shared.load(), !apiKey.isEmpty else {
            throw AIConfigError.missingAPIKey
        }

        return AIEngineConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            model: AppConfigStore.shared.selectedModel
        )
    }
}

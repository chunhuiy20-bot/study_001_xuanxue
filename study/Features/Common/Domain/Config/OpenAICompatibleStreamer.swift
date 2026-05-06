import Foundation

enum OpenAICompatibleStreamerError: LocalizedError {
    case invalidResponse
    case invalidStatus(code: Int, message: String)
    case emptyStream

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "AI 服务响应无效"
        case .invalidStatus(let code, let message):
            if message.isEmpty {
                return "AI 服务返回状态码 \(code)"
            }
            return "AI 服务错误(\(code))：\(message)"
        case .emptyStream:
            return "AI 流式返回为空"
        }
    }
}

enum OpenAICompatibleStreamer {
    static func streamChatCompletion(
        baseURL: URL,
        apiKey: String,
        model: String,
        messages: [[String: String]],
        temperature: Double = 0.7,
        maxTokens: Int? = nil,
        onDelta: @escaping @Sendable (String) async -> Void
    ) async throws -> String? {
        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        var payload: [String: Any] = [
            "model": model,
            "stream": true,
            "temperature": temperature,
            "messages": messages.map { ["role": $0["role"] ?? "user", "content": $0["content"] ?? ""] }
        ]
        if let maxTokens {
            payload["max_tokens"] = maxTokens
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])

        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenAICompatibleStreamerError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            var bodyText = ""
            for try await line in bytes.lines {
                bodyText += line
            }
            throw OpenAICompatibleStreamerError.invalidStatus(code: http.statusCode, message: normalizedErrorMessage(from: bodyText))
        }

        var hasAnyToken = false
        var finalFinishReason: String?

        for try await rawLine in bytes.lines {
            if Task.isCancelled { break }
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard line.hasPrefix("data:") else { continue }

            let payloadLine = line.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
            guard payloadLine.isEmpty == false else { continue }
            if payloadLine == "[DONE]" { break }

            guard
                let data = payloadLine.data(using: .utf8),
                let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let choices = object["choices"] as? [[String: Any]],
                let first = choices.first
            else { continue }

            if let finishReason = first["finish_reason"] as? String, finishReason.isEmpty == false {
                finalFinishReason = finishReason
            }

            if let delta = first["delta"] as? [String: Any] {
                let token = (delta["content"] as? String) ?? (delta["reasoning_content"] as? String) ?? ""
                if token.isEmpty == false {
                    hasAnyToken = true
                    await onDelta(token)
                }
            }
        }

        if hasAnyToken == false {
            throw OpenAICompatibleStreamerError.emptyStream
        }

        return finalFinishReason
    }

    private static func normalizedErrorMessage(from raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return raw
        }

        if let errorObj = object["error"] as? [String: Any],
           let message = errorObj["message"] as? String,
           message.isEmpty == false {
            return message
        }

        if let message = object["message"] as? String, message.isEmpty == false {
            return message
        }

        return raw
    }
}

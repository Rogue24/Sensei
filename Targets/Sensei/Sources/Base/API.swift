import Foundation
import Ananda
import CustomDump

enum API {
    enum Error: Swift.Error, LocalizedError {
        case missingAPIKey
        case invalidURL
        case networkFailed
        case invalidResponse(statusCode: Int, errorCode: String, message: String?)
        case invalidContent(String)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "缺少 API Key，请使用 `⌘ ,` 打开设置后添加。"
            case .invalidURL:
                return "API 地址无效，请检查 Custom Host 设置。"
            case .networkFailed:
                return "网络请求失败，请检查网络连接或 Custom Host 设置。"
            case .invalidResponse(let statusCode, let errorCode, let message):
                if statusCode == 429, errorCode == "insufficient_quota" {
                    return "OpenAI API 额度不足（429 / insufficient_quota）。请检查 API Key 对应账号的 Billing/Usage，确认已开通付款方式或更换有额度的 API Key 后重试。"
                }

                if statusCode == 429 {
                    return "请求过于频繁（429 / \(errorCode)）。请稍后重试，或检查当前模型/API Key 的速率限制。"
                }

                if statusCode == 401 {
                    return "API Key 无效或已过期（401 / \(errorCode)）。请在设置中更新 API Key。"
                }

                if statusCode == 403 {
                    return "当前 API Key 没有访问权限（403 / \(errorCode)）。请检查账号权限、项目权限或所选模型。"
                }

                let trimmedMessage = message?.trimmingCharacters(in: .whitespacesAndNewlines)

                if let trimmedMessage, !trimmedMessage.isEmpty {
                    return "请求失败（\(statusCode) / \(errorCode)）：\(trimmedMessage)"
                } else {
                    return "请求失败（\(statusCode) / \(errorCode)）。"
                }
            case .invalidContent(let content):
                return "响应内容无效：\(content)"
            }
        }
    }
}

extension API {
    struct Message: Sendable {
        enum Role: String, Sendable {
            case system
            case user
            case assistant
        }

        let role: Role
        let content: String
    }

    static func chatCompletions(
        model: ChatGPTModel,
        temperature: Double,
        messages: [Message]
    ) async throws -> AsyncThrowingStream<String, any Swift.Error> {
        let apiKey = Settings.apiKey

        guard !apiKey.isEmpty else {
            throw Error.missingAPIKey
        }

        let host: String = {
            let customHost = Settings.customHost

            if customHost.isEmpty {
                return "api.openai.com"
            } else {
                return customHost
            }
        }()

        guard let url = URL(string: "https://\(host)/v1/chat/completions") else {
            throw Error.invalidURL
        }

        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = "POST"

        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)",
        ]

        struct Input: Encodable {
            struct Message: Encodable {
                let role: String
                let content: String
            }

            let model: String
            let temperature: Double
            let stream: Bool
            let messages: [Message]
        }

        let input = Input(
            model: model.rawValue,
            temperature: temperature,
            stream: true,
            messages: messages.map {
                .init(
                    role: $0.role.rawValue,
                    content: $0.content
                )
            }
        )

        #if DEBUG
        customDump(input, name: "input")
        #endif

        urlRequest.httpBody = try JSONEncoder().encode(input)

        let (result, response) = try await URLSession.shared.bytes(for: urlRequest)

        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw Error.networkFailed
        }

        guard 200...299 ~= httpURLResponse.statusCode else {
            let errorJSONString: String = try await {
                var string = ""

                for try await line in result.lines {
                    string += line
                }

                return string
            }()

            #if DEBUG
            print("errorJSONString:", errorJSONString)
            #endif

            struct Output: AnandaModel {
                struct Error: AnandaModel {
                    let message: String
                    let type: String
                    let code: String?

                    init(json: AnandaJSON) {
                        message = json.message.string()
                        type = json.type.string()
                        code = json.code.string
                    }
                }

                let error: Error

                init(json: AnandaJSON) {
                    error = .init(json: json.error)
                }
            }

            let output = Output.decode(from: errorJSONString)

            let errorCode: String = {
                let code = output.error.code?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                let type = output.error.type.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                if let code, !code.isEmpty {
                    return code
                } else if !type.isEmpty {
                    return type
                } else {
                    return "unknown"
                }
            }()

            throw Error.invalidResponse(
                statusCode: httpURLResponse.statusCode,
                errorCode: errorCode,
                message: output.error.message
            )
        }

        struct StreamOutput: AnandaModel {
            struct Choice: AnandaModel {
                struct Delta: AnandaModel {
                    let content: String?

                    init(json: AnandaJSON) {
                        content = json.content.string
                    }
                }

                let delta: Delta
                let index: Int
                let finishReason: String?

                init(json: AnandaJSON) {
                    delta = .init(json: json.delta)
                    index = json.index.int()
                    finishReason = json.finish_reason.string
                }
            }

            let id: String
            let object: String
            let created: Date
            let model: String
            let choices: [Choice]

            init(json: AnandaJSON) {
                id = json.id.string()
                object = json.object.string()
                created = json.created.date()
                model = json.model.string()
                choices = json.choices.array().map { .init(json: $0) }
            }
        }

        return AsyncThrowingStream<String, any Swift.Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        #if DEBUG
                        print("line:", line)
                        #endif

                        if line == "data: [DONE]" {
                            break
                        }

                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8) {
                            let output = StreamOutput.decode(from: data)

                            if let content = output.choices.first?.delta.content {
                                continuation.yield(content)
                            }

                            if output.choices.first?.finishReason == "stop" {
                                break
                            }
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

import Foundation
import GRDB

enum ChatGPTModel: String, Codable, CaseIterable, DatabaseValueConvertible, Sendable {
    case gpt_5_2 = "gpt-5.2"
    case gpt_5_2_pro = "gpt-5.2-pro"
    case gpt_5 = "gpt-5"
    case gpt_5_mini = "gpt-5-mini"
    case gpt_5_nano = "gpt-5-nano"
    case gpt_4_1 = "gpt-4.1"
    case gpt_3_5_turbo = "gpt-3.5-turbo"
    case gpt_3_5_turbo_0301 = "gpt-3.5-turbo-0301"
    case gpt_4 = "gpt-4"
    case gpt_4_0314 = "gpt-4-0314"
    case gpt_4_32k = "gpt-4-32k"
    case gpt_4_32k_0314 = "gpt-4-32k-0314"
}

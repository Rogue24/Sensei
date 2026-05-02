import SwiftUI

struct AnimatedMessageToScrollTo: Equatable, Sendable {
    let animated: Bool
    let message: Message
    let anchor: UnitPoint
}

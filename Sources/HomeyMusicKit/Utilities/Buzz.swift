import SwiftUI

@MainActor
public func buzz() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}


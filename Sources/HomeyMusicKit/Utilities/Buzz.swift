import SwiftUI

@MainActor
public func buzz() {
    #if canImport(UIKit)
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
    #else
    // You could handle macOS-specific feedback here if needed
    print("Buzz feedback is not available on this platform.")
    #endif
}

import SwiftUI

public func buzz() {
    #if canImport(UIKit)
    DispatchQueue.main.async {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #else
    print("Buzz feedback is not available on this platform.")
    #endif
}

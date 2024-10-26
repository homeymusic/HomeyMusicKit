import Testing
import SwiftUI
@testable import HomeyMusicKit

struct MockIcon: IconRepresentable {
    var icon: String
    var isCustomIcon: Bool
}

final class IconRepresentableTests {

    @Test func testSystemIcon() {
        if #available(macOS 11.0, iOS 13.0, *) {
            let mockIcon = MockIcon(icon: "star.fill", isCustomIcon: false)
            let image = mockIcon.image
            #expect(image == Image(systemName: "star.fill"))
        }
    }

    @Test func testCustomIcon() {
        if #available(macOS 11.0, iOS 13.0, *) {
            let mockIcon = MockIcon(icon: "custom_icon", isCustomIcon: true)
            let image = mockIcon.image
            #expect(image == Image("custom_icon", bundle: .module))
        }
    }

    @Test func testIconProperties() {
        let mockIcon = MockIcon(icon: "custom_icon", isCustomIcon: true)
        #expect(mockIcon.icon == "custom_icon")
        #expect(mockIcon.isCustomIcon == true)
    }
}

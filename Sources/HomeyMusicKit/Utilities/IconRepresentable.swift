import SwiftUI

public protocol IconRepresentable {
    var icon: String { get }
    var isCustomIcon: Bool { get }
    
    // Provide a default implementation to return the appropriate Image view
    @available(iOS 13.0, *)
    var image: Image { get }
}

extension IconRepresentable {
    @available(iOS 13.0, *)
    public var image: Image {
        if isCustomIcon {
            return Image(icon)            // Custom image
        } else {
            return Image(systemName: icon) // System image
        }
    }
}

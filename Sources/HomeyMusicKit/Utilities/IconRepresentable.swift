import SwiftUI

public protocol IconRepresentable {
    var icon: String { get }
    var insetIcon: String { get }
    var isCustomIcon: Bool { get }
    
    // Provide a default implementation to return the appropriate Image view
    var image: Image { get }
    var insetImage: Image { get }
}

extension IconRepresentable {
    public var image: Image {
        if isCustomIcon {
            return Image(icon, bundle: .module)            // Custom image
        } else {
            return Image(systemName: icon) // System image
        }
    }
    public var insetImage: Image {
        return Image(systemName: insetIcon) // System image
    }
    
    public var insetIcon: String {
        icon
    }
    
    public var isCustomIcon: Bool {
        false
    }    
}

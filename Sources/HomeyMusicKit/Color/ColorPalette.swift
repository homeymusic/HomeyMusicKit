import SwiftUI

public protocol ColorPalette: AnyObject, Observable {
    
    // MARK: - Basic Info
    var id: UUID { get set }
    var systemIdentifier: String? { get set }
    var name: String { get set }
    var position: Int { get set }
    var isSystemPalette: Bool { get }
    
    // MARK: - Core Color Methods
    func majorMinorColor(majorMinor: MajorMinor) -> Color
    func activeColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func inactiveColor(isNatural: Bool) -> Color
    func activeTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func inactiveTextColor(majorMinor: MajorMinor, isNatural: Bool) -> Color
    func activeOutlineColor(majorMinor: MajorMinor) -> Color
    func inactiveOutlineColor(majorMinor: MajorMinor) -> Color
    
    // MARK: - Additional Color
    var benignColor: Color { get }
        
}


extension ColorPalette {
    public var isSystemPalette: Bool {
        systemIdentifier != nil
    }
}

import SwiftUI

public struct HomeyMusicKit {
    
    public enum FormFactor {
        case iPad
        case iPhone
    }
    
    @MainActor public static let formFactor: FormFactor = UIScreen.main.bounds.size.width > 1000 ? .iPad : .iPhone
    public static let primaryColor: CGColor = #colorLiteral(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1)
    public static let secondaryColor: CGColor = #colorLiteral(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1)
    public static let goldenRatio = (1 + sqrt(5)) / 2
    public static let animationStyle: Animation = Animation.linear
    
}

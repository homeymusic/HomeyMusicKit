import SwiftUI

public struct HomeyMusicKit {
    
    // MARK: - Migration Trigger
    /// This static property is lazily initialized and triggers clearing user defaults if needed.
    private static let performMigration: Void = {
        clearUserDefaultsIfNeeded()
    }()
    
    public enum FormFactor {
        case iPad
        case iPhone
    }
    
    // When accessing a static property, force the migration to occur.
    @MainActor
    public static let formFactor: FormFactor = {
        _ = HomeyMusicKit.performMigration  // Ensures migration is executed once
        return UIScreen.main.bounds.size.width > 1000 ? .iPad : .iPhone
    }()
    
    public static let primaryColor: CGColor = #colorLiteral(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1)
    public static let secondaryColor: CGColor = #colorLiteral(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1)
    public static let goldenRatio = (1 + sqrt(5)) / 2
    public static let animationStyle: Animation = Animation.linear

    /// Clears all UserDefaults if the app version has changed (or if no previous version was stored).
    public static func clearUserDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        // Retrieve current version from Info.plist.
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        // Retrieve the stored version; nil means no version stored (i.e. first run).
        let storedVersion = defaults.string(forKey: "lastAppVersion")
        
        if storedVersion == nil || storedVersion != currentVersion {
            // Remove all user defaults for this app.
            if let bundleID = Bundle.main.bundleIdentifier {
                defaults.removePersistentDomain(forName: bundleID)
                defaults.synchronize()
            }
            // Save the current version for future comparisons.
            defaults.set(currentVersion, forKey: "lastAppVersion")
        }
    }
}

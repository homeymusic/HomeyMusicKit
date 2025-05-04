import SwiftUI

public struct HomeyMusicKit {
    
    // MARK: - Migration Trigger
    /// A dedicated static property that triggers migration exactly once.
    private static let migrationTrigger: Void = {
        clearUserDefaultsIfNeeded()
    }()

    /// Call this method early in your app's lifecycle (for example, in your AppDelegate or @main App struct)
    /// to ensure that migration is executed once.
    public static func initialize() {
        _ = migrationTrigger
    }

    public static let goldenRatio = (1 + sqrt(5)) / 2
    public static let animationStyle: Animation = Animation.linear
    public static let instrumentSpace = "InstrumentSpace"
    public static let tonicPickerSpace = "TonicPickerSpace"
    public static let tonicaSpace = "TonicaSpace"
    public static let modePickerSpace = "ModePickerSpace"
    public static let isActivatedBrightnessAdjustment: CGFloat = -0.3
//    public static let modeAndTonicUnlinkedImage = Image("custom.personalhotspot.slash.circle", bundle: .module)
    public static let modeAndTonicUnlinkedImage = Image("custom.personalhotspot.slash", bundle: .module)
    
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

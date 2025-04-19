// Models/ColorPalette+SystemData.swift

import SwiftData

/// Any SwiftData model that can look itself up by systemIdentifier
public protocol SystemSeedable: PersistentModel {
    /// Return a FetchDescriptor that finds this model by its systemIdentifier
    static func fetchDescriptor(systemID: String) -> FetchDescriptor<Self>
}

extension ModelContext {
    /// Seed a bunch of “system” ColorPalette types in this context.
    /// - definitions: array of (systemID, factory) pairs
    /// - assignStatic: when an existing managed object is found, call this
    ///                 to re‑point your static var at that object.
    func seedSystemEntities<T: ColorPalette & SystemSeedable>(
        definitions: [(id: String, factory: (ModelContext) -> T)],
        assignStatic: (String, T) -> Void
    ) {
        for def in definitions {
            let fetch    = T.fetchDescriptor(systemID: def.id)
            if let existing = try? fetchFirst(fetch) {
                assignStatic(def.id, existing)
            } else {
                let instance = def.factory(self)
                insert(instance)
            }
        }
    }

    /// Fetch exactly one system palette by its systemIdentifier.
    func systemEntity<T: ColorPalette & SystemSeedable>(
        of type: T.Type,
        id: String
    ) -> T {
        let fetch = T.fetchDescriptor(systemID: id)
        return (try! fetchFirst(fetch))!
    }

    private func fetchFirst<T>(_ desc: FetchDescriptor<T>) throws -> T? {
        try fetch(desc).first
    }
}

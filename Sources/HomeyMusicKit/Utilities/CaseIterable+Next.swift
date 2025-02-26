// Sources/HomeyMusicKit/CaseIterable+Next.swift

public extension CaseIterable where Self: Equatable {
    /// Returns the next case in the enum, wrapping around to the first case if needed.
    var next: Self {
        let cases = Array(Self.allCases)
        guard let currentIndex = cases.firstIndex(of: self) else {
            return self
        }
        let nextIndex = (currentIndex + 1) % cases.count
        return cases[nextIndex]
    }
}

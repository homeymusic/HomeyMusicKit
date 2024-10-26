public var lastModuloError: String?

public func modulo(_ a: Int, _ n: Int) -> Int {
    guard n > 0 else {
        lastModuloError = "Modulus must be positive, got: \(n)"
        return 0  // Return a default value or use a custom fallback as desired
    }
    let r = a % n
    lastModuloError = nil
    return r >= 0 ? r : r + n
}

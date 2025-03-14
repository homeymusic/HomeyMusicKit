public func modulo(_ a: Int, _ n: Int) -> Int {
    guard n > 0 else {
        return 0  // Return a default value or use a custom fallback as desired
    }
    let r = a % n
    return r >= 0 ? r : r + n
}

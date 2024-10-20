/// A struct that represents a rational fraction, with a numerator and denominator.
///
/// The `Fraction` struct can be initialized with a numerator and denominator
/// or from a string representation in the format "numerator:denominator".
public struct Fraction: CustomStringConvertible, LosslessStringConvertible {
    let numerator: Int
    let denominator: Int
    
    // Conform to CustomStringConvertible to provide a string representation of the fraction.
    public var description: String {
        return "\(numerator):\(denominator)"
    }
    
    /// Initializes a `Fraction` from a string representation.
    ///
    /// - Parameter description: A string in the format "numerator:denominator".
    /// - Returns: A `Fraction` object if the string is valid, or `nil` if the format is incorrect.
    public init?(_ description: String) {
        let components = description.split(separator: ":")
        if components.count == 2,
           let num = Int(components[0]),
           let den = Int(components[1]) {
            self.numerator = num
            self.denominator = den
        } else {
            return nil
        }
    }
    
    /// Initializes a `Fraction` with a specified numerator and denominator.
    ///
    /// - Parameters:
    ///   - numerator: The numerator of the fraction.
    ///   - denominator: The denominator of the fraction.
    public init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
}

/// Swift function that converts a decimal (floating-point) number to its closest rational fraction
/// using the Stern-Brocot algorithm.
///
/// This function takes a floating-point number and approximates it as a rational
/// fraction by finding the closest fraction within a small tolerance using the
/// Stern-Brocot tree algorithm. The approximation is useful for converting
/// real numbers into rational forms such as in musical theory, physics, or graphics.
///
/// For a detailed explanation of the Stern-Brocot tree and how it works,
/// check out this excellent video on YouTube:
/// https://www.youtube.com/watch?v=DpwUVExX27E
///
/// The video covers the mathematical concepts behind the tree and
/// its practical uses, including rational number approximations.
///
/// - Parameter x: A `Double` representing the decimal number to be converted.
/// - Returns: A `Fraction` struct containing the numerator and denominator
///            that best approximates the given decimal number.
public func decimalToFraction(_ x: Double) -> Fraction {
    var sanity: Int = 0
    let insane: Int = 1000
    
    let percent_variance: Double = 0.011

    let valid_min: Double = x * (1.0 - percent_variance)
    let valid_max: Double = x * (1.0 + percent_variance)
    
    var left_num: Int    = Int(x.rounded(.down))
    var left_den: Int    = 1
    var mediant_num: Int = Int(x.rounded())
    var mediant_den: Int = 1
    var right_num: Int   = Int(x.rounded(.down)) + 1
    var right_den: Int   = 1
    
    var approximation: Double = Double(mediant_num) / Double(mediant_den)
    
    // Iteratively improve the approximation using the Stern-Brocot algorithm
    while ((approximation < valid_min) || (valid_max < approximation)) && sanity < insane {
        let x0: Double = (2.0 * x) - approximation
        if (approximation < valid_min) {
            left_num   = mediant_num
            left_den   = mediant_den
            let k: Int = Int(((Double(right_num) - x0 * Double(right_den)) / (x0 * Double(left_den) - Double(left_num))).rounded(.down))
            right_num  = right_num + k * left_num
            right_den  = right_den + k * left_den
        } else if (valid_max < approximation) {
            right_num  = mediant_num
            right_den  = mediant_den
            let k: Int = Int(((x0 * Double(left_den) - Double(left_num)) / (Double(right_num) - x0 * Double(right_den))).rounded(.down))
            left_num   = left_num + k * right_num
            left_den   = left_den + k * right_den
        }
        mediant_num    = left_num + right_num
        mediant_den    = left_den + right_den
        approximation  = Double(mediant_num) / Double(mediant_den)
        sanity += 1
    }
    
    return Fraction(numerator: mediant_num, denominator: mediant_den)
}

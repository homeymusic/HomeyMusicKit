public struct Fraction: CustomStringConvertible, LosslessStringConvertible {
    let numerator: Int
    let denominator: Int
    
    // Conform to CustomStringConvertible
    public var description: String {
        return "\(numerator):\(denominator)"
    }
    
    // Conform to LosslessStringConvertible
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
    
    // Standard initializer
    public init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
}

public func sternBrocot(_ x: Double) -> Fraction {
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
    
    while ((approximation < valid_min) || (valid_max < approximation)) && sanity < insane {
        let x0: Double = (2.0 * x) - approximation
        if (approximation < valid_min) {
            left_num   = mediant_num
            left_den   = mediant_den
            let k: Int = Int(((Double(right_num)-x0*Double(right_den))/(x0*Double(left_den)-Double(left_num))).rounded(.down))
            right_num  = right_num + k*left_num
            right_den  = right_den + k*left_den
        } else if (valid_max < approximation) {
            right_num  = mediant_num
            right_den  = mediant_den
            let k: Int = Int(((x0*Double(left_den)-Double(left_num))/(Double(right_num)-x0*Double(right_den))).rounded(.down))
            left_num   = left_num + k*right_num
            left_den   = left_den + k*right_den
        }
        mediant_num    = left_num + right_num
        mediant_den    = left_den + right_den
        approximation  = Double(mediant_num) / Double(mediant_den)
        sanity += 1
    }
    
    return Fraction(numerator: mediant_num, denominator: mediant_den)
}


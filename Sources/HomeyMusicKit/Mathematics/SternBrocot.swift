import Foundation

public struct Fraction: CustomStringConvertible, LosslessStringConvertible {
    let numerator: Int
    let denominator: Int
    
    public var description: String {
        return "\(numerator):\(denominator)"
    }
    
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
    
    public init(numerator: Int, denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
}

public func decimalToFraction(_ x: Double, _ uncertainty: Double = 1 / (4 * Double.pi)) -> Fraction {
    guard x > 0 else {
        fatalError("STOP: x must be greater than 0")
    }
    guard uncertainty > 0 else {
        fatalError("STOP: uncertainty must be greater than 0")
    }

    var cycles = 0
    if x <= uncertainty {
        cycles = 1
        if uncertainty < 1 {
            return Fraction(numerator: 1, denominator: Int(1 / uncertainty))
        } else {
            return Fraction(numerator: 1, denominator: Int(uncertainty))
        }
    }

    var approximation: Double
    let validMin = x - uncertainty
    let validMax = x + uncertainty

    var leftNum = Int(floor(x)), leftDen = 1
    var mediantNum = Int(round(x)), mediantDen = 1
    var rightNum = Int(floor(x)) + 1, rightDen = 1

    approximation = Double(mediantNum) / Double(mediantDen)
    let insane = 1000

    while ((approximation < validMin || approximation > validMax) && cycles < insane) {
        let x0 = 2 * x - approximation

        if approximation < validMin {
            leftNum = mediantNum
            leftDen = mediantDen
            let k = Int(floor((Double(rightNum) - x0 * Double(rightDen)) / (x0 * Double(leftDen) - Double(leftNum))))
            rightNum += k * leftNum
            rightDen += k * leftDen
        } else if approximation > validMax {
            rightNum = mediantNum
            rightDen = mediantDen
            let k = Int(floor((x0 * Double(leftDen) - Double(leftNum)) / (Double(rightNum) - x0 * Double(rightDen))))
            leftNum += k * rightNum
            leftDen += k * rightDen
        }

        mediantNum = leftNum + rightNum
        mediantDen = leftDen + rightDen
        approximation = Double(mediantNum) / Double(mediantDen)
        cycles += 1
    }

    guard mediantNum > 0 else {
        fatalError("STOP: mediant_num is less than or equal to zero")
    }
    guard mediantDen > 0 else {
        fatalError("STOP: mediant_den is less than or equal to zero")
    }

    return Fraction(numerator: mediantNum, denominator: mediantDen)
}

import Testing
@testable import HomeyMusicKit

final class FractionTests {

    @Test func testFractionInitializationFromString() throws {
        // Test valid string initialization
        let fraction = Fraction("3:4")
        #expect(fraction?.numerator == 3)
        #expect(fraction?.denominator == 4)
        
        // Test invalid string initialization
        let invalidFraction = Fraction("invalid")
        #expect(invalidFraction == nil)
        
        // Test another valid string
        let anotherFraction = Fraction("7:5")
        #expect(anotherFraction?.numerator == 7)
        #expect(anotherFraction?.denominator == 5)
    }

    @Test func testFractionDescription() throws {
        // Test that description returns correct format
        let fraction = Fraction(numerator: 3, denominator: 4)
        #expect(fraction.description == "3:4")
    }

    @Test func testDecimalToFractionApproximation() throws {
        // Test approximation close to 0.5
        let fraction = decimalToFraction(0.5)
        #expect(fraction.numerator == 1)
        #expect(fraction.denominator == 2)
        
        // Test approximation close to 0.333...
        let thirdApprox = decimalToFraction(1.0 / 3.0)
        #expect(thirdApprox.numerator == 1)
        #expect(thirdApprox.denominator == 3)
        
        // Test approximation for 1.25
        let onePointTwoFive = decimalToFraction(1.25)
        #expect(onePointTwoFive.numerator == 5)
        #expect(onePointTwoFive.denominator == 4)
    }
    
    @Test func testLargeNumberFraction() throws {
        // Test handling of large numerator and denominator
        let fraction = Fraction(numerator: 123456, denominator: 654321)
        #expect(fraction.numerator == 123456)
        #expect(fraction.denominator == 654321)
    }
    
    @Test func testSternBrocotDoesNotReturnZero() throws {
        let x = 0.1666667
        let uncertainty = 3.0

        let result = decimalToFraction(x, uncertainty)
        #expect(result.numerator != 0, "Stern-Brocot should never return a 0 numerator")
        #expect(result.denominator != 0, "Stern-Brocot should never return a 0 denominator")
    }
}

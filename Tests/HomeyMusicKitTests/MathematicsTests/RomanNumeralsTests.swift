import Testing

final class RomanNumeralTests {

    // Test for invalid input (numbers greater than 3999)
    @Test func testRomanNumeralInvalidInput() async throws {
        #expect(4000.romanNumeral == "Invalid input (greater than 3999)")
        #expect(5000.romanNumeral == "Invalid input (greater than 3999)")
        #expect(3999.romanNumeral != "Invalid input (greater than 3999)")
    }
    
    // Test for valid Roman numeral conversions
    @Test func testRomanNumeralValidConversions() async throws {
        #expect(1.romanNumeral == "I")
        #expect(4.romanNumeral == "IV")
        #expect(9.romanNumeral == "IX")
        #expect(10.romanNumeral == "X")
        #expect(40.romanNumeral == "XL")
        #expect(50.romanNumeral == "L")
        #expect(90.romanNumeral == "XC")
        #expect(100.romanNumeral == "C")
        #expect(400.romanNumeral == "CD")
        #expect(500.romanNumeral == "D")
        #expect(900.romanNumeral == "CM")
        #expect(1000.romanNumeral == "M")
        #expect(3999.romanNumeral == "MMMCMXCIX")
    }
    
    // Test for edge cases
    @Test func testRomanNumeralEdgeCases() async throws {
        #expect(0.romanNumeral == "")  // No representation for 0 in Roman numerals
        #expect((-1).romanNumeral == "") // No negative Roman numerals
    }
}

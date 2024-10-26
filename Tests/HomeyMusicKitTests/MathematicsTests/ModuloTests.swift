@testable import HomeyMusicKit
import Testing

final class ModuloTests {

    // Test for standard positive input
    @Test func testPositiveModulo() async throws {
        #expect(modulo(10, 3) == 1) // 10 % 3 = 1
        #expect(modulo(7, 5) == 2)  // 7 % 5 = 2
    }
    
    // Test for negative input
    @Test func testNegativeModulo() async throws {
        #expect(modulo(-10, 3) == 2) // -10 % 3 = -1, adjust to 2
        #expect(modulo(-7, 5) == 3)  // -7 % 5 = -2, adjust to 3
    }
    
    // Test for no postive modulus
    @Test func testBadModulus() async throws {
        _ = modulo(10, 0)
        #expect(lastModuloError == "Modulus must be positive, got: 0")
    }

}

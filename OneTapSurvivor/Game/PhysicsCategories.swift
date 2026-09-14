import Foundation

enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b001
    static let obstacle: UInt32 = 0b010
    static let wall: UInt32 = 0b100
}

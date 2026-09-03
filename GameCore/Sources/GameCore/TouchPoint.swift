import CoreGraphics
import Foundation

public struct TouchPoint: Identifiable, Equatable {
  public let id: UUID
  public var location: CGPoint
  public let colorIndex: Int

  public init(id: UUID, location: CGPoint, colorIndex: Int) {
    self.id = id
    self.location = location
    self.colorIndex = colorIndex
  }
}

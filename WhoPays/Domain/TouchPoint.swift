import CoreGraphics
import Foundation

struct TouchPoint: Identifiable, Equatable {
  let id: UUID
  var location: CGPoint
  let colorIndex: Int
}

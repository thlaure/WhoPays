import XCTest

@testable import GameCore

final class RandomWinnerSelectorTests: XCTestCase {
  func testEmptyCollectionHasNoWinner() {
    XCTAssertNil(RandomWinnerSelector().selectWinner(from: []))
  }

  func testSingleTouchIsAlwaysSelected() {
    let touch = TouchPoint(id: UUID(), location: .zero, colorIndex: 0)

    XCTAssertEqual(RandomWinnerSelector().selectWinner(from: [touch]), touch)
  }
}

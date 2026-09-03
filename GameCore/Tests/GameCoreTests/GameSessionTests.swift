import CoreGraphics
import XCTest

@testable import GameCore

@MainActor
final class GameSessionTests: XCTestCase {
  func testInitialStateIsWaitingWithoutTouches() {
    let session = makeSession()

    XCTAssertEqual(session.phase, .waiting)
    XCTAssertTrue(session.touches.isEmpty)
  }

  func testOneTouchKeepsSessionWaiting() {
    let session = makeSession()

    session.updateTouches([firstTouch])

    XCTAssertEqual(session.phase, .waiting)
    XCTAssertEqual(session.touches, [firstTouch])
  }

  func testTwoTouchesStartCountdown() {
    let session = makeSession()

    session.updateTouches(twoTouches)

    guard case .countingDown(let deadline) = session.phase else {
      return XCTFail("Expected countdown phase")
    }
    XCTAssertGreaterThan(deadline, Date())
  }

  func testRemovingTouchCancelsCountdown() async {
    let session = makeSession()
    session.updateTouches(twoTouches)
    await Task.yield()

    session.updateTouches([firstTouch])
    await Task.yield()

    XCTAssertEqual(session.phase, .waiting)
  }

  func testCountdownChoosesInjectedWinnerAndPlaysFeedback() async {
    let feedback = FeedbackSpy()
    let session = GameSession(
      countdownDuration: .zero,
      winnerSelector: FixedWinnerSelector(selectedID: secondTouch.id),
      winnerFeedback: feedback
    )

    session.updateTouches(twoTouches)
    await waitUntil { session.phase == .winner(self.secondTouch.id) }

    XCTAssertEqual(session.phase, .winner(secondTouch.id))
    XCTAssertEqual(feedback.playCount, 1)
  }

  func testWinnerRemainsSelectedWhileTouchesMove() async {
    let session = makeSession(duration: .zero, selectedID: firstTouch.id)
    session.updateTouches(twoTouches)
    await waitUntil { session.phase == .winner(self.firstTouch.id) }
    let movedTouch = TouchPoint(id: firstTouch.id, location: CGPoint(x: 80, y: 90), colorIndex: 0)

    session.updateTouches([movedTouch, secondTouch])

    XCTAssertEqual(session.phase, .winner(firstTouch.id))
    XCTAssertEqual(session.touches.first, movedTouch)
  }

  func testRemovingAllTouchesAfterWinnerResetsSession() async {
    let session = makeSession(duration: .zero, selectedID: firstTouch.id)
    session.updateTouches(twoTouches)
    await waitUntil { session.phase == .winner(self.firstTouch.id) }

    session.updateTouches([])

    XCTAssertEqual(session.phase, .waiting)
    XCTAssertTrue(session.touches.isEmpty)
  }

  func testManualResetRestartsCountdownWhenTouchesRemain() async {
    let session = makeSession(duration: .zero, selectedID: firstTouch.id)
    session.updateTouches(twoTouches)
    await waitUntil { session.phase == .winner(self.firstTouch.id) }

    session.reset()

    guard case .countingDown = session.phase else {
      return XCTFail("Expected a new countdown")
    }
  }

  func testMissingWinnerReturnsToWaiting() async {
    let session = GameSession(
      countdownDuration: .zero,
      winnerSelector: FixedWinnerSelector(selectedID: nil),
      winnerFeedback: FeedbackSpy()
    )

    session.updateTouches(twoTouches)
    await waitUntil { session.phase == .waiting }

    XCTAssertEqual(session.phase, .waiting)
  }

  private let firstTouch = TouchPoint(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
    location: CGPoint(x: 10, y: 20),
    colorIndex: 0
  )

  private let secondTouch = TouchPoint(
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
    location: CGPoint(x: 30, y: 40),
    colorIndex: 1
  )

  private var twoTouches: [TouchPoint] {
    [firstTouch, secondTouch]
  }

  private func makeSession(
    duration: Duration = .seconds(60),
    selectedID: UUID? = nil
  ) -> GameSession {
    GameSession(
      countdownDuration: duration,
      winnerSelector: FixedWinnerSelector(selectedID: selectedID),
      winnerFeedback: FeedbackSpy()
    )
  }

  private func waitUntil(
    timeoutIterations: Int = 100,
    condition: @escaping @MainActor () -> Bool
  ) async {
    for _ in 0..<timeoutIterations {
      if condition() { return }
      await Task.yield()
    }
    XCTFail("Condition was not met")
  }
}

private struct FixedWinnerSelector: WinnerSelecting {
  let selectedID: UUID?

  func selectWinner(from touches: [TouchPoint]) -> TouchPoint? {
    touches.first { $0.id == selectedID }
  }
}

@MainActor
private final class FeedbackSpy: WinnerFeedbackProviding {
  private(set) var playCount = 0

  func playWinnerFeedback() {
    playCount += 1
  }
}

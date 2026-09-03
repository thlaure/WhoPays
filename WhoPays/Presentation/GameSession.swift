import Foundation
import Observation

@MainActor
@Observable
final class GameSession {
  enum Phase: Equatable {
    case waiting
    case countingDown(deadline: Date)
    case winner(UUID)
  }

  private(set) var touches: [TouchPoint] = []
  private(set) var phase: Phase = .waiting

  private let countdownDuration: Duration
  private let winnerSelector: any WinnerSelecting
  private let winnerFeedback: any WinnerFeedbackProviding
  private var selectionTask: Task<Void, Never>?

  init(
    countdownDuration: Duration = .seconds(2),
    winnerSelector: any WinnerSelecting = RandomWinnerSelector(),
    winnerFeedback: any WinnerFeedbackProviding = SystemWinnerFeedback()
  ) {
    self.countdownDuration = countdownDuration
    self.winnerSelector = winnerSelector
    self.winnerFeedback = winnerFeedback
  }

  func updateTouches(_ touches: [TouchPoint]) {
    self.touches = touches

    switch phase {
    case .winner where touches.isEmpty:
      reset()
    case .winner:
      break
    case .waiting, .countingDown:
      updateCountdown()
    }
  }

  func reset() {
    cancelCountdown()
    phase = .waiting
    updateCountdown()
  }

  private func updateCountdown() {
    guard touches.count >= 2 else {
      cancelCountdown()
      phase = .waiting
      return
    }

    guard case .waiting = phase else { return }
    startCountdown()
  }

  private func startCountdown() {
    let delay = countdownDuration
    phase = .countingDown(deadline: Date().addingTimeInterval(delay.timeInterval))

    selectionTask = Task { [weak self] in
      do {
        try await Task.sleep(for: delay)
        guard !Task.isCancelled else { return }
        self?.finishCountdown()
      } catch {
        // Cancellation is the normal path when a finger leaves early.
      }
    }
  }

  private func finishCountdown() {
    selectionTask = nil

    guard let winner = winnerSelector.selectWinner(from: touches) else {
      phase = .waiting
      return
    }

    phase = .winner(winner.id)
    winnerFeedback.playWinnerFeedback()
  }

  private func cancelCountdown() {
    selectionTask?.cancel()
    selectionTask = nil
  }
}

extension Duration {
  fileprivate var timeInterval: TimeInterval {
    let components = self.components
    return Double(components.seconds)
      + Double(components.attoseconds) / 1_000_000_000_000_000_000
  }
}

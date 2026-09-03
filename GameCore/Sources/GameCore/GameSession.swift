import Foundation
import Observation

@MainActor
@Observable
public final class GameSession {
  public enum Phase: Equatable {
    case waiting
    case countingDown(deadline: Date)
    case winner(UUID)
  }

  public private(set) var touches: [TouchPoint] = []
  public private(set) var phase: Phase = .waiting

  private let countdownDuration: Duration
  private let winnerSelector: any WinnerSelecting
  private let winnerFeedback: any WinnerFeedbackProviding
  private var selectionTask: Task<Void, Never>?

  public init(
    countdownDuration: Duration = .seconds(2),
    winnerSelector: any WinnerSelecting = RandomWinnerSelector(),
    winnerFeedback: any WinnerFeedbackProviding
  ) {
    self.countdownDuration = countdownDuration
    self.winnerSelector = winnerSelector
    self.winnerFeedback = winnerFeedback
  }

  public func updateTouches(_ touches: [TouchPoint]) {
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

  public func reset() {
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
        // Cancellation is normal when a finger leaves early.
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
    let components = components
    return Double(components.seconds)
      + Double(components.attoseconds) / 1_000_000_000_000_000_000
  }
}

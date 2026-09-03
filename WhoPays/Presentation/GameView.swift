import GameCore
import SwiftUI

@MainActor
struct GameView: View {
  @State private var session: GameSession

  private let colors: [Color] = [
    .pink, .cyan, .orange, .green, .purple, .yellow, .indigo, .mint, .red, .blue,
  ]

  private var isCountingDown: Bool {
    if case .countingDown = session.phase { return true }
    return false
  }

  private var winnerID: UUID? {
    if case .winner(let id) = session.phase { return id }
    return nil
  }

  init() {
    _session = State(initialValue: GameSession(winnerFeedback: SystemWinnerFeedback()))
  }

  init(session: GameSession) {
    _session = State(initialValue: session)
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      MultiTouchSurface(onTouchesChanged: session.updateTouches)
        .ignoresSafeArea()
        .accessibilityIdentifier("touchSurface")

      ForEach(session.touches) { touch in
        FingerMarker(
          number: touch.colorIndex + 1,
          color: colors[touch.colorIndex % colors.count],
          isWinner: winnerID == touch.id,
          isCountingDown: isCountingDown
        )
        .position(touch.location)
        .allowsHitTesting(false)
      }

      GameChrome(
        phase: session.phase,
        touchCount: session.touches.count,
        isCountingDown: isCountingDown
      )
      .allowsHitTesting(false)
    }
    .animation(.spring(response: 0.45, dampingFraction: 0.68), value: session.phase)
    .animation(.easeOut(duration: 0.18), value: session.touches)
    .persistentSystemOverlays(.hidden)
  }
}

#Preview {
  GameView()
}

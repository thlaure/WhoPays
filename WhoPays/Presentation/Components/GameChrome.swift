import SwiftUI

struct GameChrome: View {
  let phase: GameSession.Phase
  let touchCount: Int
  let isCountingDown: Bool

  private var title: LocalizedStringResource {
    switch phase {
    case .waiting:
      touchCount == 0 ? GameText.placeFingers : GameText.addFinger
    case .countingDown:
      GameText.holdStill
    case .winner:
      GameText.winner
    }
  }

  private var statusText: LocalizedStringResource {
    switch phase {
    case .waiting:
      GameText.minimumPlayers
    case .countingDown:
      GameText.suspense
    case .winner:
      GameText.removeFingers
    }
  }

  private var statusIcon: String {
    switch phase {
    case .waiting: "hand.point.up.left.fill"
    case .countingDown: "hourglass"
    case .winner: "creditcard.fill"
    }
  }

  var body: some View {
    VStack(spacing: 16) {
      GameHeader(title: title)
      Spacer()
      StatusPill(text: statusText, icon: statusIcon, isAnimated: isCountingDown)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 28)
  }
}

private struct GameHeader: View {
  let title: LocalizedStringResource

  var body: some View {
    VStack(spacing: 6) {
      Text(GameText.brand)
        .font(.system(size: 15, weight: .black, design: .rounded))
        .textCase(.uppercase)
        .tracking(4)
        .foregroundStyle(.white.opacity(0.6))

      Text(title)
        .font(.system(size: 32, weight: .black, design: .rounded))
        .multilineTextAlignment(.center)
        .contentTransition(.numericText())
    }
  }
}

private struct StatusPill: View {
  let text: LocalizedStringResource
  let icon: String
  let isAnimated: Bool

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.title2.bold())
        .symbolEffect(.pulse, isActive: isAnimated)
      Text(text)
        .font(.system(.headline, design: .rounded, weight: .semibold))
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 20)
    .padding(.vertical, 15)
    .background(.ultraThinMaterial, in: Capsule())
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("gameStatus")
  }
}

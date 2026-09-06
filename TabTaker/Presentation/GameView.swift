import GameCore
import SwiftUI

@MainActor
struct GameView: View {
  @State private var session: GameSession
  @State private var adManager: GoogleInterstitialAdManager
  @State private var isMenuPresented = false
  @State private var isAdsInfoPresented = false
  @State private var pendingMenuAction: AppMenuAction?

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
    _adManager = State(initialValue: GoogleInterstitialAdManager())
  }

  init(session: GameSession) {
    _session = State(initialValue: session)
    _adManager = State(initialValue: GoogleInterstitialAdManager())
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

      VStack {
        HStack {
          Spacer()
          AppMenuButton(action: { isMenuPresented = true })
        }
        Spacer()
      }
      .padding(20)
      .offset(y: -12)
    }
    .sheet(isPresented: $isMenuPresented, onDismiss: handleMenuDismissal) {
      AppMenuView(
        isAdPreferencesAvailable: adManager.isPrivacyOptionsRequired,
        onSelect: { pendingMenuAction = $0 }
      )
    }
    .alert(GameText.aboutAds, isPresented: $isAdsInfoPresented) {
      Button(GameText.done, role: .cancel) {}
    } message: {
      Text(GameText.aboutAdsMessage)
    }
    .task {
      adManager.prepare()
    }
    .onChange(of: session.phase) { _, phase in
      switch phase {
      case .winner:
        adManager.recordCompletedRound()
      case .waiting:
        adManager.presentIfEligible()
      case .countingDown:
        break
      }
    }
    .animation(.spring(response: 0.45, dampingFraction: 0.68), value: session.phase)
    .animation(.easeOut(duration: 0.18), value: session.touches)
    .persistentSystemOverlays(.hidden)
  }

  private func handleMenuDismissal() {
    defer { pendingMenuAction = nil }

    switch pendingMenuAction {
    case .adPreferences:
      adManager.presentPrivacyOptions()
    case .aboutAds:
      isAdsInfoPresented = true
    case nil:
      break
    }
  }
}

#Preview {
  GameView()
}

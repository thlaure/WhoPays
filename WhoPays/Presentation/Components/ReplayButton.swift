import SwiftUI

struct ReplayButton: View {
  let isVisible: Bool
  let action: () -> Void

  var body: some View {
    VStack {
      Spacer()
      Button(action: action) {
        Label(GameText.playAgain, systemImage: "arrow.counterclockwise")
          .font(.headline)
          .padding(.horizontal, 22)
          .padding(.vertical, 14)
          .background(.white, in: Capsule())
          .foregroundStyle(.black)
      }
      .accessibilityIdentifier("resetButton")
      .padding(.bottom, 118)
    }
    .opacity(isVisible ? 1 : 0)
    .allowsHitTesting(isVisible)
    .accessibilityHidden(!isVisible)
  }
}

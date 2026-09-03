import SwiftUI

struct FingerMarker: View {
  let number: Int
  let color: Color
  let isWinner: Bool
  let isCountingDown: Bool

  var body: some View {
    ZStack {
      Circle()
        .stroke(color.opacity(0.35), lineWidth: 5)
        .frame(width: isWinner ? 156 : 94, height: isWinner ? 156 : 94)
        .scaleEffect(isCountingDown ? 1.08 : 1)

      Circle()
        .fill(color.gradient)
        .frame(width: isWinner ? 112 : 72, height: isWinner ? 112 : 72)
        .shadow(color: color.opacity(isWinner ? 0.9 : 0.45), radius: isWinner ? 28 : 12)

      markerContent
    }
    .scaleEffect(isWinner ? 1.08 : 1)
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private var markerContent: some View {
    if isWinner {
      Image(systemName: "creditcard.fill")
        .font(.system(size: 35, weight: .black))
        .foregroundStyle(.white)
        .transition(.scale.combined(with: .opacity))
    } else {
      Text("\(number)")
        .font(.system(size: 25, weight: .black, design: .rounded))
        .foregroundStyle(.white)
    }
  }
}

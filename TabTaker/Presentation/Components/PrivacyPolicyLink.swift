import SwiftUI

struct PrivacyPolicyLink: View {
  private static let privacyPolicyURL = URL(
    string: "https://thlaure.github.io/TabTaker/privacy-policy"
  )!

  var body: some View {
    Link(destination: Self.privacyPolicyURL) {
      Label(GameText.privacyPolicy, systemImage: "hand.raised.fill")
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
    .accessibilityIdentifier("privacyPolicy")
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    PrivacyPolicyLink()
  }
}

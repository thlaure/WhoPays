import SwiftUI

struct PrivacyOptionsButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "hand.raised.fill")
        .font(.headline)
        .foregroundStyle(.white)
        .padding(12)
        .background(.ultraThinMaterial, in: Circle())
    }
    .accessibilityLabel(GameText.privacyOptions)
    .accessibilityIdentifier("privacyOptions")
  }
}

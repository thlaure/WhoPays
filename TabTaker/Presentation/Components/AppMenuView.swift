import SwiftUI

enum AppMenuAction {
  case adPreferences
  case aboutAds
}

enum PrivacyPolicy {
  static let url = URL(string: "https://thlaure.github.io/TabTaker/privacy-policy")!
}

struct AppMenuButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "ellipsis")
        .font(.headline.weight(.bold))
        .foregroundStyle(.white)
        .frame(width: 44, height: 44)
        .background(.ultraThinMaterial, in: Circle())
    }
    .accessibilityLabel(GameText.openMenu)
    .accessibilityIdentifier("appMenu")
  }
}

struct AppMenuView: View {
  @Environment(\.dismiss) private var dismiss

  let isAdPreferencesAvailable: Bool
  let onSelect: (AppMenuAction) -> Void

  var body: some View {
    VStack(spacing: 0) {
      Text(GameText.menu)
        .font(.title2.bold())
        .padding(.bottom, 12)

      Link(destination: PrivacyPolicy.url) {
        AppMenuRow(
          title: GameText.privacyPolicy,
          subtitle: "menu.privacy_policy.description",
          systemImage: "hand.raised.fill"
        )
      }
      .accessibilityIdentifier("privacyPolicy")

      Divider()

      if isAdPreferencesAvailable {
        Button {
          onSelect(.adPreferences)
          dismiss()
        } label: {
          AppMenuRow(
            title: GameText.adPreferences,
            subtitle: GameText.adPreferencesDescription,
            systemImage: "slider.horizontal.3"
          )
        }
        .accessibilityIdentifier("adPreferences")
      } else {
        AppMenuRow(
          title: GameText.adPreferences,
          subtitle: GameText.adPreferencesUnavailable,
          systemImage: "slider.horizontal.3",
          showsChevron: false
        )
        .opacity(0.5)
      }

      Divider()

      Button {
        onSelect(.aboutAds)
        dismiss()
      } label: {
        AppMenuRow(
          title: GameText.aboutAds,
          subtitle: GameText.aboutAdsDescription,
          systemImage: "info.circle"
        )
      }
      .accessibilityIdentifier("aboutAds")

      Button(GameText.done, action: dismiss.callAsFunction)
        .font(.headline)
        .padding(.top, 20)
    }
    .padding(24)
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
  }
}

private struct AppMenuRow: View {
  let title: LocalizedStringResource
  let subtitle: LocalizedStringResource
  let systemImage: String
  var showsChevron = true

  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: systemImage)
        .font(.title3)
        .frame(width: 28)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.body.weight(.semibold))
        Text(subtitle)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Spacer()

      if showsChevron {
        Image(systemName: "chevron.right")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(.tertiary)
      }
    }
    .foregroundStyle(.primary)
    .padding(.vertical, 16)
    .contentShape(Rectangle())
  }
}

#Preview {
  AppMenuView(isAdPreferencesAvailable: true, onSelect: { _ in })
}

import GameCore
import GoogleMobileAds
import Observation
import UserMessagingPlatform

@MainActor
@Observable
final class GoogleInterstitialAdManager: NSObject {
  private enum Configuration {
    #if DEBUG
      static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
      static let interstitialAdUnitID = "ca-app-pub-6057515359834957/4726847484"
    #endif
  }

  private var displayPolicy = InterstitialAdDisplayPolicy()
  private var interstitialAd: InterstitialAd?
  private var isPreparing = false

  private(set) var isPrivacyOptionsRequired = false

  func prepare() {
    guard !isPreparing else { return }
    isPreparing = true

    ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters()) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        defer { self.isPreparing = false }

        try? await ConsentForm.loadAndPresentIfRequired(from: nil)
        self.isPrivacyOptionsRequired =
          ConsentInformation.shared.privacyOptionsRequirementStatus == .required

        guard ConsentInformation.shared.canRequestAds else { return }
        await MobileAds.shared.start()
        await self.loadInterstitialIfNeeded()
      }
    }
  }

  func recordCompletedRound() {
    displayPolicy.recordCompletedRound()
  }

  func presentIfEligible() {
    guard let interstitialAd, displayPolicy.consumePresentationEligibility() else { return }
    interstitialAd.present(from: nil)
  }

  func presentPrivacyOptions() {
    Task {
      try? await ConsentForm.presentPrivacyOptionsForm(from: nil)
      isPrivacyOptionsRequired =
        ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
  }

  private func loadInterstitialIfNeeded() async {
    guard interstitialAd == nil else { return }

    do {
      interstitialAd = try await InterstitialAd.load(
        with: Configuration.interstitialAdUnitID,
        request: Request()
      )
      interstitialAd?.fullScreenContentDelegate = self
    } catch {
      // Ads are optional. A later round retries loading without affecting the game.
    }
  }
}

extension GoogleInterstitialAdManager: FullScreenContentDelegate {
  nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    Task { @MainActor in
      interstitialAd = nil
      await loadInterstitialIfNeeded()
    }
  }

  nonisolated func ad(
    _ ad: FullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    Task { @MainActor in
      interstitialAd = nil
      await loadInterstitialIfNeeded()
    }
  }
}

public struct InterstitialAdDisplayPolicy {
  private let roundsBetweenAds: Int
  private var completedRounds = 0

  public init(roundsBetweenAds: Int = 4) {
    precondition(roundsBetweenAds > 0, "roundsBetweenAds must be positive.")
    self.roundsBetweenAds = roundsBetweenAds
  }

  public mutating func recordCompletedRound() {
    completedRounds += 1
  }

  public mutating func consumePresentationEligibility() -> Bool {
    guard completedRounds >= roundsBetweenAds else { return false }
    completedRounds = 0
    return true
  }
}

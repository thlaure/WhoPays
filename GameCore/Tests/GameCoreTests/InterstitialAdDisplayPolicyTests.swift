import XCTest

@testable import GameCore

final class InterstitialAdDisplayPolicyTests: XCTestCase {
  func testDoesNotPresentBeforeConfiguredRoundCount() {
    var policy = InterstitialAdDisplayPolicy(roundsBetweenAds: 4)

    for _ in 0..<3 {
      policy.recordCompletedRound()
      XCTAssertFalse(policy.consumePresentationEligibility())
    }
  }

  func testPresentsAfterConfiguredRoundCount() {
    var policy = InterstitialAdDisplayPolicy(roundsBetweenAds: 4)

    for _ in 0..<4 {
      policy.recordCompletedRound()
    }

    XCTAssertTrue(policy.consumePresentationEligibility())
  }

  func testPresentationEligibilityIsConsumedOnlyOnce() {
    var policy = InterstitialAdDisplayPolicy(roundsBetweenAds: 1)
    policy.recordCompletedRound()

    XCTAssertTrue(policy.consumePresentationEligibility())
    XCTAssertFalse(policy.consumePresentationEligibility())
  }
}

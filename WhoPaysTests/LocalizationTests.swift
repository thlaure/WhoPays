import XCTest

@testable import WhoPays

final class LocalizationTests: XCTestCase {
  func testFrenchTranslationsAreComplete() {
    assertTranslations(
      languageCode: "fr",
      expected: [
        "action.play_again": "Rejouer",
        "brand": "Qui paie ?",
        "status.minimum_players": "Au moins 2 joueurs",
        "status.remove_fingers": "Retirez les doigts pour rejouer",
        "status.suspense": "Suspense…",
        "title.add_finger": "Encore un doigt !",
        "title.hold_still": "Ne bougez plus…",
        "title.place_fingers": "Posez vos doigts",
        "title.winner": "C’est toi qui paies !",
      ]
    )
  }

  func testEnglishTranslationsAreComplete() {
    assertTranslations(
      languageCode: "en",
      expected: [
        "action.play_again": "Play again",
        "brand": "Who pays?",
        "status.minimum_players": "At least 2 players",
        "status.remove_fingers": "Remove fingers to play again",
        "status.suspense": "Suspense…",
        "title.add_finger": "One more finger!",
        "title.hold_still": "Hold still…",
        "title.place_fingers": "Place your fingers",
        "title.winner": "You're paying!",
      ]
    )
  }

  private func assertTranslations(languageCode: String, expected: [String: String]) {
    guard
      let localizationPath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
      let localizedBundle = Bundle(path: localizationPath)
    else {
      return XCTFail("Missing localization bundle for \(languageCode)")
    }

    for (key, value) in expected {
      XCTAssertEqual(
        localizedBundle.localizedString(forKey: key, value: nil, table: nil),
        value,
        "Unexpected translation for \(key) in \(languageCode)"
      )
    }
  }
}

import XCTest

@testable import TabTaker

final class LocalizationTests: XCTestCase {
  func testFrenchTranslationsAreComplete() {
    assertTranslations(
      languageCode: "fr",
      expected: [
        "brand": "Qui paie ?",
        "menu.about_ads": "À propos des publicités",
        "menu.about_ads.description": "Les pubs apparaissent entre les parties",
        "menu.about_ads.message":
          "Les pubs peuvent apparaître entre les parties, au maximum une fois toutes les quatre parties terminées.",
        "menu.ad_preferences": "Préférences publicitaires",
        "menu.ad_preferences.description": "Gérez le consentement et les choix publicitaires",
        "menu.ad_preferences.unavailable":
          "Aucune préférence publicitaire n’est requise sur cet appareil",
        "menu.done": "Fermer",
        "menu.open": "Ouvrir le menu",
        "menu.privacy_policy.description": "Découvrez le traitement de vos données",
        "menu.title": "Menu",
        "privacy.policy": "Politique de confidentialité",
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
        "brand": "Who pays?",
        "menu.about_ads": "About ads",
        "menu.about_ads.description": "Ads appear between games",
        "menu.about_ads.message":
          "Ads may appear between games, no more than once every four completed rounds.",
        "menu.ad_preferences": "Ad preferences",
        "menu.ad_preferences.description": "Manage consent and advertising choices",
        "menu.ad_preferences.unavailable": "Ad preferences are not required on this device",
        "menu.done": "Done",
        "menu.open": "Open menu",
        "menu.privacy_policy.description": "Read how your data is handled",
        "menu.title": "Menu",
        "privacy.policy": "Privacy Policy",
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

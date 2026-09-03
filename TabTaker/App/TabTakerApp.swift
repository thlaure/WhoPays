import SwiftUI

@main
struct TabTakerApp: App {
  var body: some Scene {
    WindowGroup {
      GameView()
        .preferredColorScheme(.dark)
    }
  }
}

import SwiftUI

@main
struct WhoPaysApp: App {
  var body: some Scene {
    WindowGroup {
      GameView()
        .preferredColorScheme(.dark)
    }
  }
}

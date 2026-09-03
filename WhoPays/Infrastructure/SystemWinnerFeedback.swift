import UIKit

struct SystemWinnerFeedback: WinnerFeedbackProviding {
  func playWinnerFeedback() {
    let notification = UINotificationFeedbackGenerator()
    notification.prepare()
    notification.notificationOccurred(.success)

    Task {
      try? await Task.sleep(for: .milliseconds(180))
      UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1)
    }
  }
}

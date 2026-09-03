import GameCore
import SwiftUI
import UIKit

struct MultiTouchSurface: UIViewRepresentable {
  let onTouchesChanged: ([TouchPoint]) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onTouchesChanged: onTouchesChanged)
  }

  func makeUIView(context: Context) -> TouchTrackingView {
    let view = TouchTrackingView()
    view.backgroundColor = .clear
    view.isMultipleTouchEnabled = true
    view.onTouchesChanged = context.coordinator.handleTouches
    return view
  }

  func updateUIView(_ uiView: TouchTrackingView, context: Context) {
    context.coordinator.onTouchesChanged = onTouchesChanged
  }

  final class Coordinator {
    var onTouchesChanged: ([TouchPoint]) -> Void

    init(onTouchesChanged: @escaping ([TouchPoint]) -> Void) {
      self.onTouchesChanged = onTouchesChanged
    }

    func handleTouches(_ touches: [TouchPoint]) {
      onTouchesChanged(touches)
    }
  }
}

final class TouchTrackingView: UIView {
  var onTouchesChanged: (([TouchPoint]) -> Void)?

  private struct TrackedTouch {
    let id: UUID
    let colorIndex: Int
    var location: CGPoint
  }

  private var trackedTouches: [ObjectIdentifier: TrackedTouch] = [:]
  private var nextColorIndex = 0

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let key = ObjectIdentifier(touch)
      guard trackedTouches[key] == nil else { continue }

      trackedTouches[key] = TrackedTouch(
        id: UUID(),
        colorIndex: nextColorIndex,
        location: touch.location(in: self)
      )
      nextColorIndex += 1
    }
    publishTouches()
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      trackedTouches[ObjectIdentifier(touch)]?.location = touch.location(in: self)
    }
    publishTouches()
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    remove(touches)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    remove(touches)
  }

  private func remove(_ touches: Set<UITouch>) {
    for touch in touches {
      trackedTouches.removeValue(forKey: ObjectIdentifier(touch))
    }

    if trackedTouches.isEmpty {
      nextColorIndex = 0
    }
    publishTouches()
  }

  private func publishTouches() {
    let points = trackedTouches.values
      .map { TouchPoint(id: $0.id, location: $0.location, colorIndex: $0.colorIndex) }
      .sorted { $0.colorIndex < $1.colorIndex }
    onTouchesChanged?(points)
  }
}

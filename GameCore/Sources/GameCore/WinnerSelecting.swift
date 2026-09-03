public protocol WinnerSelecting {
  func selectWinner(from touches: [TouchPoint]) -> TouchPoint?
}

public struct RandomWinnerSelector: WinnerSelecting {
  public init() {}

  public func selectWinner(from touches: [TouchPoint]) -> TouchPoint? {
    touches.randomElement()
  }
}

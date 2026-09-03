protocol WinnerSelecting {
  func selectWinner(from touches: [TouchPoint]) -> TouchPoint?
}

struct RandomWinnerSelector: WinnerSelecting {
  func selectWinner(from touches: [TouchPoint]) -> TouchPoint? {
    touches.randomElement()
  }
}

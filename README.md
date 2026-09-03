# WhoPays

WhoPays is a small, offline iOS party game. Two or more people place a finger on the screen, keep their fingers down for two seconds, and the app randomly chooses who pays.

The project is intentionally small, but structured as a production-quality Swift application. It uses SwiftUI for the interface, a minimal UIKit bridge for true multi-touch input, dependency injection for testability, and no external dependencies.

## Features

- Simultaneous multi-touch tracking
- A distinct color and number for every finger
- Two-second countdown that is cancelled when fewer than two fingers remain
- Random winner selection
- Winner animation and haptic feedback
- Automatic reset after all fingers are removed
- Manual **Play again** button
- English and French localization
- Fully offline: no backend, account, analytics, or authentication

## Requirements

- Xcode 16 or later
- iOS 17 or later
- A physical iPhone is recommended for realistic multi-touch and haptic testing

## Running the app

1. Open `WhoPays.xcodeproj` in Xcode.
2. Select the **WhoPays** scheme.
3. Choose an iPhone simulator or a connected iPhone.
4. Press `⌘R`, or choose **Product > Run**.

When using a physical device, select your Apple development team under **Signing & Capabilities** if Xcode asks for one.

The app follows the device language automatically. English is the development language, and French is also included. You can test a specific language from the scheme settings in Xcode under **Run > Options > App Language**.

> The simulator is useful for compiling, launching, and checking the interface. A physical iPhone provides a much better test of several independent fingers and actual haptic feedback.

## How a round works

```mermaid
sequenceDiagram
    actor Players
    participant UIKit as TouchTrackingView (UIKit)
    participant Bridge as MultiTouchSurface
    participant Session as GameSession
    participant Selector as WinnerSelecting
    participant UI as SwiftUI
    participant Haptics as SystemWinnerFeedback

    Players->>UIKit: Place fingers on screen
    UIKit->>Bridge: Publish active touches
    Bridge->>Session: updateTouches(...)

    alt Fewer than two fingers
        Session->>Session: Stay in waiting state
    else Two or more fingers
        Session->>Session: Start two-second task
        Session->>Selector: Select from current touches
        Selector-->>Session: Return winning touch
        Session-->>UI: Phase becomes winner(id)
        UI-->>Players: Animate winning marker
        Session->>Haptics: Play success feedback
    end

    Players->>UIKit: Remove all fingers
    UIKit->>Session: Publish empty touch list
    Session-->>UI: Reset to waiting state
```

SwiftUI is declarative: `GameSession` does not tell individual labels or circles how to redraw themselves. It changes its state, and SwiftUI automatically rebuilds the affected view descriptions.

## State machine

The game can only be in one of three phases. Modeling these phases with a Swift `enum` prevents contradictory states such as “waiting” and “winner” being active at the same time.

```mermaid
stateDiagram-v2
    [*] --> Waiting

    Waiting --> Waiting: 0 or 1 active finger
    Waiting --> CountingDown: At least 2 active fingers

    CountingDown --> Waiting: Finger count drops below 2
    CountingDown --> Winner: 2 seconds complete

    Winner --> Winner: Fingers remain on screen
    Winner --> Waiting: All fingers removed
    Winner --> CountingDown: Play again with 2+ fingers
```

## Architecture

The architecture keeps business rules independent from Apple-specific input and feedback APIs. It is a lightweight application of Clean Architecture rather than a large framework or a collection of unnecessary layers.

```mermaid
flowchart TD
    App[App<br/>Composition root] --> Presentation
    Presentation[Presentation<br/>SwiftUI views and GameSession] --> Domain
    Presentation --> FeedbackPort[WinnerFeedbackProviding]
    Infrastructure[Infrastructure<br/>UIKit touch input and haptics] --> Presentation
    Infrastructure -. implements .-> FeedbackPort
    Resources[Resources<br/>English and French strings] --> Presentation
    Tests[WhoPaysTests<br/>Deterministic unit tests] --> Domain
    Tests --> Presentation

    style Domain fill:#222,color:#fff,stroke:#888
    style Presentation fill:#222,color:#fff,stroke:#888
    style Infrastructure fill:#222,color:#fff,stroke:#888
    style App fill:#222,color:#fff,stroke:#888
    style Resources fill:#222,color:#fff,stroke:#888
    style Tests fill:#222,color:#fff,stroke:#888
```

The dependency direction matters:

- **Domain** contains the core concepts and winner-selection contract.
- **Presentation** depends on the domain and exposes observable state to SwiftUI.
- **Infrastructure** adapts UIKit and haptic APIs to the application's own types and protocols.
- **App** creates the root view and connects the pieces.
- **Tests** replace random selection and haptics with predictable test doubles.

## Project structure

```text
WhoPays/
├── WhoPays.xcodeproj/
│   └── xcshareddata/xcschemes/
│       └── WhoPays.xcscheme
├── WhoPays/
│   ├── App/
│   │   └── WhoPaysApp.swift
│   ├── Domain/
│   │   ├── TouchPoint.swift
│   │   └── WinnerSelecting.swift
│   ├── Infrastructure/
│   │   ├── MultiTouchSurface.swift
│   │   └── SystemWinnerFeedback.swift
│   ├── Presentation/
│   │   ├── Components/
│   │   │   ├── FingerMarker.swift
│   │   │   ├── GameChrome.swift
│   │   │   └── ReplayButton.swift
│   │   ├── GameSession.swift
│   │   ├── GameText.swift
│   │   ├── GameView.swift
│   │   └── WinnerFeedbackProviding.swift
│   └── Resources/
│       └── Localizable.xcstrings
└── WhoPaysTests/
    ├── GameSessionTests.swift
    ├── LocalizationTests.swift
    └── RandomWinnerSelectorTests.swift
```

## File guide

### App

`WhoPaysApp.swift` is the application entry point. It creates the main window and displays `GameView`.

### Domain

`TouchPoint.swift` defines the app's representation of a finger: a stable identifier, a position, and a color index.

`WinnerSelecting.swift` defines the winner-selection protocol and its production implementation, `RandomWinnerSelector`. The protocol allows tests to substitute a deterministic selector.

### Presentation

`GameSession.swift` owns the game state. It receives touch updates, starts and cancels the countdown, asks for a winner, and requests haptic feedback. The `@Observable` macro lets SwiftUI react to its state changes.

`GameView.swift` composes the full-screen interface. It owns a `GameSession`, places one marker per active touch, and passes state to smaller components.

`GameChrome.swift` displays the title and current instruction. It derives both from the current game phase.

`FingerMarker.swift` draws a player's colored marker and its winner appearance.

`ReplayButton.swift` is a small reusable component. It receives visibility and an action instead of depending directly on `GameSession`.

`GameText.swift` centralizes typed references to localization keys.

`WinnerFeedbackProviding.swift` defines the haptic-feedback boundary used by `GameSession`.

### Infrastructure

`MultiTouchSurface.swift` bridges UIKit into SwiftUI with `UIViewRepresentable`. UIKit reports `touchesBegan`, `touchesMoved`, `touchesEnded`, and `touchesCancelled`; the bridge converts these events into `[TouchPoint]` values.

`SystemWinnerFeedback.swift` implements `WinnerFeedbackProviding` with Apple's notification and impact feedback generators.

### Resources

`Localizable.xcstrings` is the Xcode String Catalog containing every English and French user-facing string.

### Tests

`GameSessionTests.swift` verifies the state machine, countdown cancellation, deterministic winner selection, feedback request, movement handling, and reset behavior.

`RandomWinnerSelectorTests.swift` verifies the boundary cases of random selection.

`LocalizationTests.swift` verifies that every expected English and French translation is present in the built application bundle.

## Dependency injection

Production code creates `GameSession` with default dependencies:

```swift
GameSession(
  countdownDuration: .seconds(2),
  winnerSelector: RandomWinnerSelector(),
  winnerFeedback: SystemWinnerFeedback()
)
```

Tests inject predictable replacements:

```swift
GameSession(
  countdownDuration: .zero,
  winnerSelector: FixedWinnerSelector(selectedID: expectedID),
  winnerFeedback: FeedbackSpy()
)
```

This keeps tests fast and reliable. They do not wait two real seconds, depend on randomness, or attempt to vibrate a simulator.

## Tests and coverage

Run the complete test suite with `⌘U`, or choose **Product > Test** in Xcode.

The shared **WhoPays** scheme has code coverage enabled. Open the latest test report in Xcode's Report navigator to inspect coverage by target and source file.

The domain selection logic and the `GameSession` state machine have 100% line coverage. UIKit event delivery, SwiftUI rendering, and physical haptic output are integration boundaries; they are verified through builds and device or simulator checks instead of artificial unit tests.

## Design principles

- Readability over premature optimization
- One clear source of truth for game state
- Value types for domain data
- Protocols at external or nondeterministic boundaries
- Dependency injection for deterministic tests
- `@MainActor` for UI-owned mutable state
- Small SwiftUI views with explicit inputs
- Stable SwiftUI view trees for predictable identity and animation
- Native String Catalog localization
- No external dependencies without a demonstrated need

## Data and privacy

WhoPays does not collect or transmit data. It has no networking, backend, authentication, analytics, advertising SDK, or persistent user profile.

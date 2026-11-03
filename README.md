# QuotesAppLegacy — Working Effectively with Legacy iOS Code

An educational iOS UIKit project intentionally built with common "corporate legacy" anti-patterns.

The goal of this repository is to practice **working inside an existing legacy codebase** and **delivering a new feature (`User List`) using Clean Architecture, SOLID principles, and Test-Driven Development (TDD)**—without breaking the existing working functionality.

---

## Background & Existing Codebase

This project simulates a typical rushed MVP / office legacy iOS project that you often inherit in the real world. Currently, the app has a 2-tab `MainTabBarController`:

1. **Quotes Tab (`QuotesViewController`)** — **Working Legacy Feature**:
   Fetches and displays a list of quotes from `https://dummyjson.com/quotes`.
2. **User Tab (`UserViewController`)** — **Empty Placeholder**:
   An empty screen ready for you to build the new **User List** feature.

### Intentional Legacy Code Smells (What You Are Inheriting)

The existing **Quotes** feature was deliberately written with the following classic anti-patterns:

1. **Massive View Controller (MVC)**:
   - `QuotesViewController` handles UI creation, layout, `UITableViewDataSource`, `UITableViewDelegate`, loading/error state management, presentation string formatting, and network calls all in one file.
2. **Monolithic Singleton `APIManager`**:
   - Uses a global concrete singleton (`APIManager.shared`) with `private init()`.
   - Represents an enterprise-grade God-Class that dictates all network traffic, custom headers (`X-Platform`, `X-App-Version`, `Authorization`), and logging.
   - Has **no protocols, no abstractions, and no Dependency Injection (DI)**.
   - Feature-specific endpoints (`fetchQuotes`) are accumulated via extensions (`APIManager+Quotes.swift`).
3. **No Separation of Concerns**:
   - `QuotesViewController` directly calls `APIManager.shared.fetchQuotes(...)` inside `viewDidLoad`.
   - Raw network DTOs (`[QuoteResponse]`) are stored directly as view controller state and formatted inline inside `cellForRowAt`.
4. **Zero Unit Tests**:
   - The existing code is tightly coupled to UIKit and `URLSession.shared`, with no test coverage.

---

## Project Structure

```text
QuotesAppLegacy/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── MainTabBarController.swift     # Root 2-tab bar controller (Quotes & User)
├── Networking/
│   ├── APIManager.swift               # Core legacy singleton networking manager (DO NOT MODIFY)
│   └── APIManager+Quotes.swift        # Legacy feature extension for /quotes
├── Models/
│   └── QuoteResponse.swift            # Raw network DTOs for /quotes
├── Controllers/
│   ├── QuotesViewController.swift     # Legacy Massive View Controller (Quotes tab)
│   └── UserViewController.swift       # Empty placeholder for your challenge (User tab)
├── Assets.xcassets/
├── Base.lproj/
└── Info.plist
```

---

## The Challenge: Build the `User List` Feature Cleanly

Your mission is to implement the **User List** feature inside the **User** tab using the DummyJSON Users API:

```text
GET https://dummyjson.com/users
```

### Strict Rules & Challenge Constraints

1. **Strictly DO NOT TOUCH or Modify `APIManager.swift`:**
   - In real-world enterprise environments, company compliance mandates that all HTTP traffic must route through the existing `APIManager.shared` pipeline.
   - **Do not modify `APIManager.swift`**, do not rewrite it, and **do not create a parallel `URLSession` / Alamofire network engine**.
   - You must bridge this legacy engine into your clean world using the **Adapter Pattern** (Anti-Corruption Layer).
2. **Zero Breaking Changes / Regression:**
   - The **Quotes** tab (`QuotesViewController`) must remain 100% operational as-is.
3. **Apply Clean Code & Clean Architecture:**
   - Decouple your new **User List** feature from concrete classes using abstractions/protocols (e.g., `HTTPClient`, `UserListLoader`).
   - Separate Domain Models, API Loaders/Mappers, Presentation Logic (MVP, MVVM, or VIPER), and UIKit Views.
   - Compose dependencies cleanly in the Composition Root (`MainTabBarController` or Router/Coordinator) rather than accessing `APIManager.shared` directly inside UI components.
4. **Practice Pure Test-Driven Development (TDD):**
   - Write unit tests first (**Red → Green → Refactor**) for your new User feature components (Loaders, Mappers, Presenters/ViewModels).
   - Ensure all tests run fast, deterministically, and completely offline using test doubles (Spies/Mocks/Stubs)—never hitting the live internet in unit tests.

---

## Recommended Asynchronous Patterns

To handle asynchronous data streams and bridge callbacks into modern, reactive, or declarative architectures, you are strongly encouraged to choose one of the following paradigms:

* **Swift Concurrency (`async/await`)**:
  - Bridge `APIManager.get` completion handlers into `async/await` using `withCheckedThrowingContinuation`.
* **Combine**:
  - Wrap network operations into `Future` or `AnyPublisher` for a clean functional-reactive pipeline.
* **RxSwift**:
  - Wrap network operations into `Single<(Data, HTTPURLResponse)>` or `Observable` to build reactive state-driven presentation layers.

---

## Getting Started

1. Open `QuotesAppLegacy.xcodeproj` in Xcode.
2. Build and run (`Cmd + R`) on an iOS Simulator.
3. Verify that the **Quotes** tab loads quotes from `https://dummyjson.com/quotes`.
4. Switch to the **User** tab (`UserViewController`), create your `HTTPClient` protocol and `APIManagerAdapter`, and start building the **User List** feature with **TDD & Clean Architecture**!

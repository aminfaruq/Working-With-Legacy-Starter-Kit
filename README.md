# QuotesAppLegacy — Working Effectively with Legacy iOS Code

An educational iOS UIKit project intentionally built with common "corporate legacy" anti-patterns.

The goal of this repository is to practice **working inside an existing legacy codebase** and **delivering a new feature (`User List`) using Clean Architecture, SOLID principles, and Test-Driven Development (TDD)**—without breaking the existing working functionality.

---

##  Background & Existing Codebase

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
   - Although it looks "reusable" on the surface with generic `get<T: Decodable>` and `post<T: Decodable>` helpers, it has **no protocols, no abstractions, and no Dependency Injection (DI)**.
   - Directly calls `URLSession.shared.dataTask` with a hardcoded `baseURL`, making it impossible to mock or unit test without hitting the live internet.
   - Feature-specific endpoints (`fetchQuotes`) are accumulated directly inside `APIManager`.
3. **No Separation of Concerns**:
   - `QuotesViewController` directly calls `APIManager.shared.fetchQuotes(...)` inside `viewDidLoad`.
   - Raw network DTOs (`[QuoteResponse]`) are stored directly as view controller state and formatted inline inside `cellForRowAt`.
4. **Zero Unit Tests**:
   - The existing code is tightly coupled to UIKit and `URLSession.shared`, with no test coverage.

---

##  Project Structure

```text
QuotesAppLegacy/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── MainTabBarController.swift     # Root 2-tab bar controller (Quotes & User)
├── Networking/
│   └── APIManager.swift               # Legacy singleton networking manager
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

##  The Challenge: Build the `User List` Feature Cleanly

Your mission is to implement the **User List** feature inside the **User** tab using the DummyJSON Users API:

```text
GET https://dummyjson.com/users
```

### Challenge Requirements

1. **Do Not Break Existing Functionality**:
   - The **Quotes** tab (`QuotesViewController`) must continue to work as expected.
2. **Apply Clean Code & Clean Architecture**:
   - Decouple the new **User List** feature from concrete implementations using protocols/interfaces and Dependency Injection.
   - Separate Domain models, Networking/Repository abstractions, Presentation logic (e.g., MVVM / MVP / VIP), and UIKit views.
   - Compose dependencies cleanly (e.g., in the Composition Root / `MainTabBarController` or a Factory/Coordinator) rather than calling `APIManager.shared` directly inside `UserViewController`.
3. **Bridge or Abstract Legacy Networking Safely**:
   - You may either introduce a clean `HTTPClient` abstraction or wrap/adapt `APIManager` behind a protocol (Adapter Pattern) so that your new `User` feature remains 100% testable and decoupled from `APIManager.shared`.
4. **Practice Test-Driven Development (TDD)**:
   - Write unit tests first (Red → Green → Refactor) for your new `User` feature components (Use Cases / Service / ViewModel / Presenter / Mapper).
   - Ensure all tests run fast, deterministically, and completely offline using mocks/stubs/spies—never hitting the live network in unit tests.

---

##  Getting Started

1. Open `QuotesAppLegacy.xcodeproj` in Xcode.
2. Build and run (`Cmd + R`) on an iOS Simulator.
3. Verify that the **Quotes** tab loads quotes from `https://dummyjson.com/quotes`.
4. Switch to the **User** tab (`UserViewController`) and start building the **User List** feature with **TDD & Clean Architecture**!

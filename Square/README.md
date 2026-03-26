//
//  README.md
//  Square
//
//  Created by Dhawal Mahajan on 25/03/26.
//

# Square — iOS GitHub Repos Viewer

A clean architecture iOS app built with UIKit that fetches and displays GitHub repositories. Designed with testability, separation of concerns, and maintainability at its core.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                  Presentation                   │
│         RepoViewModel  ←→  RepoListVC           │
│              ↑ State-driven UI                  │
├─────────────────────────────────────────────────┤
│                    Domain                       │
│         FetchReposUseCase  ←  RepoRepository    │
│                    ↓                            │
├─────────────────────────────────────────────────┤
│                     Data                        │
│      RepoRepositoryImpl  ←  APIService          │
│              RepoDTO  →  RepoMapper             │
└─────────────────────────────────────────────────┘
```

The app follows a strict unidirectional data flow:

**User Action → ViewModel → UseCase → Repository → API → DTO → Domain Model → State → UI**

---

## ✅ Design Patterns Used

### MVVM (UIKit-friendly)
The `RepoViewModel` holds all business logic and exposes state via a closure (`onStateChange`). The `RepoListViewController` is purely reactive — it only renders what the ViewModel tells it to. No logic lives in the view layer.

### Repository Pattern
`RepoRepository` is a protocol defined in the Domain layer. `RepoRepositoryImpl` lives in the Data layer and is the only class that knows about networking. The Domain and Presentation layers never touch `URLSession` or `APIService` directly.

### UseCase Pattern
`FetchReposUseCase` encapsulates a single business operation. It sits between the ViewModel and the Repository, keeping the ViewModel thin and making business rules easy to test in isolation.

### Dependency Injection
All dependencies flow inward via constructor injection. `APIService` accepts a `URLSession`, `RepoRepositoryImpl` accepts an `APIService`, and `RepoViewModel` accepts a `FetchReposUseCase`. Nothing creates its own dependencies internally — this is what makes the entire stack mockable in tests.

### State Pattern ⭐
UI rendering is driven entirely by `RepoState`:



The ViewController switches on this enum and renders accordingly. There are no boolean flags like `isLoading` or scattered UI update calls — a single state change triggers one clean render. This eliminates entire classes of UI bugs.

### Adapter Pattern
`RepoDTO` (the raw API response shape) is kept separate from `Repo` (the domain model). The `RepoMapper` / `toDomain()` method adapts the DTO into a clean domain object. The rest of the app never sees raw API JSON shapes.

### Factory Pattern
`AppFactory` wires up the full dependency graph at app startup. It constructs `APIService → RepoRepositoryImpl → FetchReposUseCase → RepoViewModel → RepoListViewController` in one place, keeping construction logic out of all other classes.

---

## 📁 Project Structure

### Core App

```
Square/
├── AppDelegate.swift                       # App lifecycle (minimal)
├── SceneDelegate.swift                     # Window & root VC setup
├── Factory/
│   └── AppFactory.swift                    # Dependency graph wiring
│
├── Presentation/
│   ├── RepoListViewController.swift        # Table view controller
│   ├── RepoTableViewCell.swift             # Custom cell with image + labels
│   ├── RepoViewModel.swift                 # State management & business logic
│   └── ImageCacheManager.swift             # In-memory image cache
│
├── Domain/
│   ├── Models/
│   │   └── Repo.swift                      # Domain model (no framework imports)
│   ├── Repositories/
│   │   └── RepoRepository.swift            # Protocol boundary
│   └── Usecases/
│       └── FetchReposUseCase.swift         # Business rule: fetch paginated repos
│
└── Data/
    ├── ApiService/
    │   └── APIService.swift                # Network layer (URLSession wrapper)
    ├── RepoRepositoryImpl/
    │   └── RepoRepositoryImpl.swift         # Implements RepoRepository
    └── DTO + Mapper/
        └── RepoDTO.swift                   # API response model + toDomain()
```

### Tests

```
SquareTests/
├── Data/
│   ├── APIServiceTests.swift               # Network decoding & URLError tests
│   └── RepoRepositoryTests.swift           # MockURLProtocol integration tests
│
├── Domain/
│   └── FetchReposUseCaseTests.swift        # UseCase logic tests
│
├── Presentation/
│   ├── RepoViewModelTests.swift            # State transition & error mapping
│   └── ImageCacheManagerTests.swift        # Caching & deduping logic
│
├── Mocks/
│   ├── MockAPIService.swift                # Injectable API stub
│   ├── MockRepoRepository.swift            # Stub with shouldFail flag
│   └── MockURLProtocol.swift               # Intercepts URLSession calls
│
└── Stubs/
    ├── RepoStub.swift                      # Pre-built domain objects
    ├── APIResponseStub.json                # Fixture: sample repos from API
    └── JSONLoader.swift                    # Helper: loads .json from bundle
```

### UI Tests

```
SquareUITests/
├── Flows/                                  # (Reserved for complex user flows)
└── Screens/
    └── RepoListUITests.swift               # Launch, scroll, landscape layout verification
```

---

## 🧪 Testing Strategy

The test suite is structured in three independent layers, each testing a different slice of the stack.

### Layer 1 — ViewModel Tests (`RepoViewModelTests`)
Uses `MockRepoRepository` to bypass all networking. Tests state sequences (`loading → success`, `loading → error`), empty results, multiple fetch calls, and correct error message propagation. The ViewModel's `scheduler` is injected as `{ $0() }` in tests to make async dispatch synchronous.

### Layer 2 — UseCase Tests (`FetchReposUseCaseTests`)
Uses `MockRepoRepository` to verify that `FetchReposUseCase` correctly forwards results and errors. Keeps the test scope narrow — only the use case logic is under test.

### Layer 3 — Repository Tests (`RepoRepositoryTests`)
Uses `MockURLProtocol` to intercept real `URLSession` calls. Tests actual JSON decoding against `APIResponseStub.json`, parsing failure with empty `Data()`, and network failure with `URLError`. This layer verifies the full Data layer stack without hitting the network.

### Key Testing Techniques

| Technique | Purpose |
|---|---|
| `MockURLProtocol` | Intercepts URLSession at transport level — no real network |
| `MockRepoRepository` | Decouples ViewModel/UseCase tests from Data layer |
| Injectable `scheduler` | Makes `DispatchQueue.main.async` synchronous in tests |
| `JSONLoader` | Loads `.json` fixture files from the test bundle |
| `RepoStub` | Shared pre-built domain objects — no duplication across tests |

---

## 🔑 Key Implementation Notes

**Why `self.session` matters in `APIService`**
The session must be stored and used as `self.session.dataTask(...)` — never `URLSession.shared.dataTask(...)`. Using `.shared` bypasses the injected mock session and hits the real network, breaking all repository-level tests.

**Why `RepoRepository` is a protocol**
The Domain layer defines the protocol; the Data layer implements it. This inversion means the ViewModel and UseCase depend on an abstraction, not a concrete type — making them trivially mockable and completely decoupled from networking.

**Why `RepoState` has an `idle` case**
The initial state before any fetch is triggered. This prevents the UI from rendering a loading spinner on first launch before the user (or the system) triggers a fetch.

---

## 🚀 Getting Started

1. Clone the repository
2. Open `Square.xcodeproj` in Xcode
3. Select a simulator and press `Cmd+R` to run
4. Press `Cmd+U` to run the full test suite

No external dependencies. No package manager setup required.

---

## 📋 Requirements

- Xcode 16
- iOS 26
- Swift 6.2.3

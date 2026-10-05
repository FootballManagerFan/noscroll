import SwiftUI

/// The plans the paywall offers. Prices and trial length come from the store once real billing
/// is wired; until then the UI shows bracketed placeholders.
enum ProPlan: String, CaseIterable, Identifiable {
    case yearly
    case weekly

    var id: String { rawValue }
}

enum PurchaseError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable: "Purchases aren't available in this build yet."
        }
    }
}

/// Seam for billing. `StubPurchaseService` stands in until a RevenueCat / StoreKit
/// implementation replaces it — swap the instance passed to `Entitlements`.
protocol PurchaseService {
    func isProActive() -> Bool
    func purchase(_ plan: ProPlan) async throws -> Bool
    func restore() async throws -> Bool
}

/// Never charges anyone. DEBUG builds can flip Pro on to exercise the gated UI; release builds
/// report purchases as unavailable instead of pretending to succeed.
struct StubPurchaseService: PurchaseService {
    static let debugProKey = "ns.debug.pro"

    var defaults: UserDefaults = .standard

    func isProActive() -> Bool {
        #if DEBUG
        return defaults.bool(forKey: Self.debugProKey)
        #else
        return false
        #endif
    }

    func purchase(_ plan: ProPlan) async throws -> Bool {
        #if DEBUG
        defaults.set(true, forKey: Self.debugProKey)
        return true
        #else
        throw PurchaseError.notAvailable
        #endif
    }

    func restore() async throws -> Bool {
        isProActive()
    }
}

@MainActor
final class Entitlements: ObservableObject {
    @Published private(set) var isPro: Bool

    private let service: PurchaseService

    init(service: PurchaseService = StubPurchaseService()) {
        self.service = service
        isPro = service.isProActive()
    }

    func purchase(_ plan: ProPlan) async throws {
        isPro = try await service.purchase(plan)
    }

    func restore() async throws {
        isPro = try await service.restore()
    }

    #if DEBUG
    func debugSetPro(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: StubPurchaseService.debugProKey)
        isPro = on
    }
    #endif
}

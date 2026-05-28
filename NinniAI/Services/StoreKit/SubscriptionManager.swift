import SwiftUI
import Observation

// MARK: - Subscription Manager
/// Merkezi Premium Gateway — tüm uygulama genelinde premium durumunu yönetir.
/// StoreKitManager'ın abonelik durumunu tek bir `isPro` bayrağında toplar
/// ve paywall tetikleme mekanizmasını (`showPaywall`) sağlar.
///
/// Kullanım:
/// ```swift
/// // App seviyesinde:
/// @State private var subscriptionManager = SubscriptionManager(storeKit: storeKit)
///
/// ContentView()
///     .environment(subscriptionManager)
///
/// // Herhangi bir View'da:
/// @Environment(SubscriptionManager.self) var subscription
/// ```
@Observable
final class SubscriptionManager {
    
    // MARK: - Public State
    
    /// Kullanıcı premium abone mi?
    /// StoreKitManager.isSubscribed ile senkronize kalır.
    var isPro: Bool = false
    
    /// Paywall sheet'ini tetikler.
    /// Herhangi bir view `showPaywall = true` yaparak paywall'u açabilir.
    var showPaywall: Bool = false
    
    // MARK: - Dependencies
    
    private let storeKit: StoreKitManager
    
    // MARK: - Init
    
    init(storeKit: StoreKitManager) {
        self.storeKit = storeKit
        self.isPro = storeKit.isSubscribed
    }
    
    // MARK: - Sync
    
    /// StoreKitManager ile senkronizasyonu güncelle.
    /// Transaction değişikliklerinden sonra çağrılmalı.
    @MainActor
    func syncSubscriptionStatus() async {
        await storeKit.updateSubscriptionStatus()
        isPro = storeKit.isSubscribed
    }
    
    /// StoreKitManager referansı — PaywallView satın alma akışı için
    var store: StoreKitManager { storeKit }
}

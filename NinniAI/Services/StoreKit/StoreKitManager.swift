import StoreKit
import Observation

// MARK: - StoreKit Manager
/// StoreKit 2 API wrapper — Premium abonelik yönetimi.
/// PRD §5: "Premium: Tüm sesler, gelişmiş analizler, sınırsız favoriler"
///
/// Auto-renewable subscription lifecycle:
/// 1. Ürünleri yükle (App Store Connect'ten)
/// 2. Satın alma akışını başlat
/// 3. Transaction doğrulama
/// 4. Entitlement güncelleme
@Observable
final class StoreKitManager {
    
    // MARK: - State
    
    /// Mevcut ürünler
    private(set) var products: [Product] = []
    
    /// Aktif abonelik var mı?
    private(set) var isSubscribed: Bool = false
    
    /// Aktif abonelik ürünü
    private(set) var activeSubscription: Product?
    
    /// Yükleme durumu
    private(set) var isLoading: Bool = false
    
    /// Hata mesajı
    private(set) var errorMessage: String?
    
    /// Satın alma işlemi devam ediyor mu?
    private(set) var isPurchasing: Bool = false
    
    // MARK: - Private
    
    private var updateListenerTask: Task<Void, Never>?
    
    /// Product ID'leri
    private let productIDs: [String] = PremiumPlan.allCases.map(\.productIdentifier)
    
    // MARK: - Init
    
    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updateSubscriptionStatus() }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    /// App Store Connect'ten ürünleri yükle
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await Product.products(for: Set(productIDs))
            products = storeProducts.sorted { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = "Ürünler yüklenemedi: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Purchase
    
    /// Satın alma akışını başlat
    @MainActor
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()
                isPurchasing = false
                return true
                
            case .userCancelled:
                isPurchasing = false
                return false
                
            case .pending:
                isPurchasing = false
                return false
                
            @unknown default:
                isPurchasing = false
                return false
            }
        } catch {
            errorMessage = "Satın alma başarısız: \(error.localizedDescription)"
            isPurchasing = false
            return false
        }
    }
    
    // MARK: - Restore
    
    /// Önceki satın almaları geri yükle
    @MainActor
    func restorePurchases() async {
        isLoading = true
        try? await AppStore.sync()
        await updateSubscriptionStatus()
        isLoading = false
    }
    
    // MARK: - Subscription Status
    
    /// Abonelik durumunu güncelle
    @MainActor
    func updateSubscriptionStatus() async {
        var foundActive = false
        
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productType == .autoRenewable {
                    foundActive = true
                    activeSubscription = products.first {
                        $0.id == transaction.productID
                    }
                }
            }
        }
        
        isSubscribed = foundActive
    }
    
    // MARK: - Transaction Listener
    
    /// Arka planda transaction değişikliklerini dinle
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await transaction.finish()
                    await self?.updateSubscriptionStatus()
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helpers
    
    /// Aylık ürün
    var monthlyProduct: Product? {
        products.first { $0.id == PremiumPlan.monthly.productIdentifier }
    }
    
    /// Yıllık ürün
    var yearlyProduct: Product? {
        products.first { $0.id == PremiumPlan.yearly.productIdentifier }
    }
}

// MARK: - Store Error
enum StoreError: LocalizedError {
    case failedVerification
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "İşlem doğrulanamadı."
        }
    }
}


import Foundation

struct ShopItem: Identifiable, Codable {
    let id: UUID
    let lifelineType: LifelineType
    let quantity: Int
    let price: Int
    
    init(lifelineType: LifelineType, quantity: Int = 1, price: Int) {
        self.id = UUID()
        self.lifelineType = lifelineType
        self.quantity = quantity
        self.price = price
    }
}

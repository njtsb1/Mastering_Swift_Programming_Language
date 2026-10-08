import UIKit
import Foundation

// MARK: - Enums
enum FoodType {
    case appetizer
    case mainCourse
    case dessert
}

// MARK: - Structs
struct Dish {
    var name: String
    var type: FoodType
    var price: Double
}

// MARK: - Classes & Concurrency
class Restaurant {
    var name: String
    private var _dishes: [Dish] = []
    private let queue = DispatchQueue(label: "com.example.restaurant.queue", attributes: .concurrent)
    
    var dishes: [Dish] {
        return queue.sync { _dishes }
    }
    
    init(name: String) {
        self.name = name
    }
    
    func addDish(name: String, type: FoodType, price: Double) {
        let newDish = Dish(name: name, type: type, price: price)
        queue.async(flags: .barrier) { [weak self] in
            self?._dishes.append(newDish)
        }
    }
    
    lazy var listDishes: (FoodType) -> Void = { [weak self] type in
        guard let self = self else { return }
        
        self.queue.sync {
            print("\n--- Dishes of type: \(type) ---")
            let filteredDishes = self._dishes.filter { $0.type == type }
            
            if filteredDishes.isEmpty {
                print("No dishes available for this type.")
            } else {
                for dish in filteredDishes {
                    print("- \(dish.name) ($ \(dish.price) USD)")
                }
            }
        }
    }
}

// MARK: - Execution Flow
let restaurant = Restaurant(name: "Brazilian Delights")

// Adding the updated items and prices to the menu
restaurant.addDish(name: "Chicken Croquette or Chicken pastry", type: .appetizer, price: 1.20)
restaurant.addDish(name: "Set Meal", type: .mainCourse, price: 7.50)
restaurant.addDish(name: "Brigadier or Condensed Milk Flan", type: .dessert, price: 1.80)

// Safe delay for thread synchronization before listing
DispatchQueue.main.pushAsyncAfter(deadline: .now() + 0.5) {
    restaurant.listDishes(.appetizer)
    restaurant.listDishes(.mainCourse)
    restaurant.listDishes(.dessert)
}

import Foundation

protocol ViewModelDelegate: AnyObject {}

class ViewModel {
    var items: [Item] = []
    
    weak var delegate: ViewModelDelegate?
    
    init(delegate: ViewModelDelegate) {
        self.delegate = delegate
    }
}

extension ViewModel {
    private func fetchItems() {
        items = [
            Item(id: UUID(), name: "Café espresso", value: 8.90),
            Item(id: UUID(), name: "Croissant", value: 9.00)
        ]
    }
}

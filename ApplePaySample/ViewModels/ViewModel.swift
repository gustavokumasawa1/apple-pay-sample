import Foundation

protocol ViewModelDelegate: AnyObject {
    
}

class ViewModel {
    weak var delegate: ViewModelDelegate?
    
    init(delegate: ViewModelDelegate) {
        self.delegate = delegate
    }
    
    
}

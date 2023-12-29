import UIKit
import PassKit

protocol ApplePayViewDelegate: AnyObject {
    func paymentSuccess()
    func paymentFailure()
    func getItems() -> [Item]
}

class ApplePayView: UIView {
    private lazy var applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var unavailableLabel: UILabel = {
        let label = UILabel()
        label.text = "Apple Pay unavailable"
        return label
    }()
    
    private weak var delegate: ApplePayViewDelegate?
    private let payHandler = ApplePayHandler()
    
    init(delegate: ApplePayViewDelegate, frame: CGRect = .zero) {
        super.init(frame: frame)
        self.delegate = delegate
        setupInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ApplePayView {
    private func setupInterface() {
        switch payHandler.checkApplePayStatus() {
        case .canMakePayments:
            applePayButton.addTarget(self, action: #selector(payPressed), for: .touchUpInside)
            addSubview(applePayButton)
            setupConstraints(for: applePayButton)
            
        case .needToSetupCards:
            applePayButton.addTarget(self, action: #selector(setupPressed), for: .touchUpInside)
            addSubview(applePayButton)
            setupConstraints(for: applePayButton)
            
        case .applePayUnavailable:
            addSubview(unavailableLabel)
            setupConstraints(for: unavailableLabel)
        }
    }
    
    private func setupConstraints(for view: UIView) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func payPressed(sender: AnyObject) {
        guard let items = delegate?.getItems() else {
            return
        }
        
        payHandler.startPayment(withItems: items) { [weak self] success in
            if success {
                self?.delegate?.paymentSuccess()
            } else {
                self?.delegate?.paymentFailure()
            }
        }
    }
    
    @objc private func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
}

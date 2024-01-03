import UIKit

class ViewController: UIViewController {
    private lazy var applePayView: ApplePayView = {
        let view = ApplePayView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var applePayStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Status"
        return label
    }()
    
    private lazy var viewModel = ViewModel(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        view.addSubview(applePayView)
        view.addSubview(applePayStatusLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            applePayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            applePayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applePayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applePayView.heightAnchor.constraint(equalToConstant: 40),
            
            applePayStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applePayStatusLabel.topAnchor.constraint(equalTo: applePayView.bottomAnchor, constant: 20)
        ])
    }
}

extension ViewController: ViewModelDelegate {}

extension ViewController: ApplePayViewDelegate {
    func paymentSuccess() {
        applePayStatusLabel.text = "Transação realizada com sucesso"
    }
    
    func paymentFailure() {
        applePayStatusLabel.text = "Transação falhou"
    }
    
    func getCheckoutItems() -> [Item] {
        return viewModel.items
    }
}

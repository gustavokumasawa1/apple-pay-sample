import Foundation
import PassKit

typealias ApplePayPaymentCompletion = (_ success: Bool) -> Void

class ApplePayHandler: NSObject {
    private var paymentController: PKPaymentAuthorizationController?
    private var paymentCompletion: ApplePayPaymentCompletion!
    private var paymentStatus = PKPaymentAuthorizationStatus.failure
    private let supportedNetworks: [PKPaymentNetwork] = [
        .amex,
        .discover,
        .masterCard,
        .visa
    ]
    
    func checkApplePayStatus() -> ApplePayStatus {
        if PKPaymentAuthorizationController.canMakePayments() {
            return .canMakePayments
        }
        if PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks) {
            return .needToSetupCards
        }
        return .applePayUnavailable
    }
    
    func startPayment(withItems items: [Item], completion: @escaping ApplePayPaymentCompletion) {
        paymentCompletion = completion
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = convertToSummaryItems(items)
        paymentRequest.countryCode = "BR"
        paymentRequest.currencyCode = "BRL"
        paymentRequest.supportedNetworks = supportedNetworks
        paymentRequest.merchantCapabilities = .threeDSecure
        paymentRequest.merchantIdentifier = "MERCHANT_IDENTIFIER" // TODO: change to correct merchant identifier
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present { [weak self] presented in
            if !presented {
                self?.paymentCompletion(false)
            }
        }
    }
}

extension ApplePayHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        var errors: [Error] = []
        var status: PKPaymentAuthorizationStatus = .success
        
        // TODO: paymente validations
        // TODO: handle payment.token with API
        
        paymentStatus = status
        completion(PKPaymentAuthorizationResult(status: status, errors: errors))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.paymentCompletion(true)
                } else {
                    self.paymentCompletion(false)
                }
                
                self.resetPaymentStatus()
            }
        }
    }
}

extension ApplePayHandler {
    private func convertToSummaryItems(_ items: [Item]) -> [PKPaymentSummaryItem] {
        var total: Double = 0.0
        let summaryItems: [PKPaymentSummaryItem] = items.map { item in
            total += item.value
            
            return PKPaymentSummaryItem(
                label: item.name,
                amount: NSDecimalNumber(value: item.value),
                type: .final
            )
        }
        let totalItem = PKPaymentSummaryItem(
            label: "Café do Kuma",
            amount: NSDecimalNumber(value: total),
            type: .final
        )
        
        return summaryItems + [totalItem]
    }
    
    private func resetPaymentStatus() {
        paymentStatus = .failure
    }
}

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Public Properties
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Public Methods
    func presentAlert(model: AlertModel) {
        guard let viewController = delegate?.viewControllerForPresenting else { return }
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}

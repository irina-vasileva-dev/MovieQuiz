import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionIndexLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var isButtonsEnabled = true {
        didSet { updateButtonsState() }
    }
    
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        presenter?.noButtonClicked()
    }
    
    // MARK: - MovieQuizViewControllerProtocol
    
    func setButtonsEnabled(_ enabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isButtonsEnabled = enabled
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: step)
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.showResultsAlert(with: result)
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateImageBorder(isCorrectAnswer: isCorrectAnswer)
        }
    }
    
    func showLoadingIndicator() {
        setLoadingIndicatorVisible(true)
    }
    
    func hideLoadingIndicator() {
        setLoadingIndicatorVisible(false)
    }
    
    func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showErrorAlert(message: message)
        }
    }
}

// MARK: - Private Methods

private extension MovieQuizViewController {
    
    func setupUI() {
        setFonts()
        setCornerRadius()
    }
    
    private func setFonts() {
        let mediumFont = UIFont(name: "YSDisplay-Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        let boldFont = UIFont(name: "YSDisplay-Bold", size: 23) ?? .systemFont(ofSize: 23, weight: .bold)
        
        noButton.titleLabel?.font = mediumFont
        yesButton.titleLabel?.font = mediumFont
        questionTitleLabel.font = mediumFont
        questionIndexLabel.font = mediumFont
        textLabel.font = boldFont
    }

   private func setCornerRadius() {
        imageView.layer.cornerRadius = 20
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
    }
    
    private func updateButtonsState() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            let alpha: CGFloat = self.isButtonsEnabled ? 1.0 : 0.5
            
            [self.yesButton, self.noButton].forEach { button in
                button?.alpha = alpha
                button?.isEnabled = self.isButtonsEnabled
            }
        }
    }
    
    private func updateUI(with step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        questionIndexLabel.text = step.questionNumber
        isButtonsEnabled = true
    }
    
    private func updateImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private func setLoadingIndicatorVisible(_ visible: Bool) {
        DispatchQueue.main.async { [weak self] in
            if visible {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func showResultsAlert(with result: QuizResultsViewModel) {
        guard let message = presenter?.makeResultsMessage() else { return }
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.presenter?.restartGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.presenter?.restartGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
}

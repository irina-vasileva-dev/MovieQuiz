import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionIndexLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var showQuestions: Set<QuizQuestion> = []
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?

    private var isButtonsEnabled = true {
        didSet {
            updateButtonsState()
        }
    }

    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        _ = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.displayQuestion(question)
        }
    }

    // MARK: - AlertPresenterDelegate
    
    var alertModel: AlertModel?
    var viewControllerForPresenting: UIViewController? { self }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupServices()
        showFirstQuestion()
    }
    
    // MARK: - Configuration
    
    private func configureAppearance() {
        setFonts()
        setCornerRadius()
    }
    
    private func setFonts() {
        let mediumFont = UIFont(name: "YSDisplay-Medium", size: 20) ?? .systemFont(
            ofSize: 20,
            weight: .medium
        )
        let boldFont = UIFont(name: "YSDisplay-Bold", size: 23) ?? .systemFont(
            ofSize: 23,
            weight: .bold
        )
        
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
    
    private func setupServices() {
        let factory = QuestionFactory()
        factory.delegate = self
        questionFactory = factory
        
        let presenter = AlertPresenter()
        presenter.delegate = self
        alertPresenter = presenter
        
        statisticService = StatisticService()
    }
    
    // MARK: - Game Flow
    
    private func showFirstQuestion() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard isButtonsEnabled, let currentQuestion = currentQuestion else {
            return
        }
        
        isButtonsEnabled = false
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func proceedToNextStep() {
        if currentQuestionIndex >= questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showQuestions = []
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - UI Updates
    
    private func updateButtonsState() {
        UIView.animate(withDuration: 0.3) {
            self.yesButton.alpha = self.isButtonsEnabled ? 1.0 : 0.5
            self.noButton.alpha = self.isButtonsEnabled ? 1.0 : 0.5
            self.yesButton.isEnabled = self.isButtonsEnabled
            self.noButton.isEnabled = self.isButtonsEnabled
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextStep()
        }
    }
    
    private func displayQuestion(_ question: QuizQuestion) {
        let viewModel = convert(model: question)
        updateUI(with: viewModel)
        isButtonsEnabled = true
    }
    
    private func updateUI(with viewModel: QuizStepModel) {
        imageView.layer.borderWidth = 0
        imageView.image = viewModel.image
        textLabel.text = viewModel.question
        questionIndexLabel.text = viewModel.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepModel {
        // Исправляем отображение номера вопроса - currentQuestionIndex уже увеличился
        let questionNumber = currentQuestionIndex + 1
        return QuizStepModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.question,
            questionNumber: "\(questionNumber)/\(questionsAmount)"
        )
    }
    
    private func showFinalResults() {
        guard let statisticService = statisticService else { return }
        
        let actualCorrectAnswers = min(correctAnswers, questionsAmount)
        
        statisticService
            .store(correct: actualCorrectAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let bestCorrect = min(bestGame.correct, bestGame.total)
        
        let resultText = """
                 Ваш результат: \(actualCorrectAnswers)/\(questionsAmount)
                 Количество сыгранных квизов: \(statisticService.gamesCount)
                 Рекорд: \(bestCorrect)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                 Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                 """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: resultText,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.restartGame()
            }
        )
        
        self.alertModel = alertModel
        alertPresenter?.presentAlert()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
}

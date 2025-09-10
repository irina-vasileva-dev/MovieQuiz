import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    //MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?

    //MARK: - Private Properties

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "The Dark Knight",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "Kill Bill",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "The Avengers",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "Deadpool",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "The Green Knight",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: true),

        QuizQuestion(
            image: "Old",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: false),

        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: false),

        QuizQuestion(
            image: "Tesla",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: false),

        QuizQuestion(
            image: "Vivarium",
            question: "Рейтинг этого фильма \nбольше чем 6?",
            correctAnswer: false),
    ]

    private var usedQuestionIndices: Set<Int> = []

    //MARK: - Public Methods

    func requestNextQuestion() {
        let availableIndices = questions.indices.filter {
            !usedQuestionIndices.contains($0)
        }
            
        guard let randomIndex = availableIndices.randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
            
        usedQuestionIndices.insert(randomIndex)
            
        let question = questions[randomIndex]
        delegate?.didReceiveNextQuestion(question: question)
    }
        
    func resetUsedQuestions() {
        usedQuestionIndices.removeAll()
    }
}

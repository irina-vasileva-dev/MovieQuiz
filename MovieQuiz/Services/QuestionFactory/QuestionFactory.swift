import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    //MARK: - Private Properties
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    //MARK: - Public Methods
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
 
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            guard let rating = Float(movie.rating) else { return }
            
            // Генерируем разнообразные вопросы
            let (questionText, correctAnswer) = self.generateChallengingQuestion(for: rating)
            
            let question = QuizQuestion(
                image: imageData,
                text: questionText,
                correctAnswer: correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    // MARK: - Challenging Question Generation
    
    private func generateChallengingQuestion(for rating: Float) -> (text: String, correctAnswer: Bool) {
        // Случайно выбираем тип вопроса: 50% "больше", 50% "меньше"
        let isGreaterQuestion = Bool.random()
        
        if isGreaterQuestion {
            // Вопрос "больше чем X?"
            return generateGreaterQuestion(for: rating)
        } else {
            // Вопрос "меньше чем X?"
            return generateLessQuestion(for: rating)
        }
    }
    
    private func generateGreaterQuestion(for rating: Float) -> (text: String, correctAnswer: Bool) {
        // Для вопроса "больше чем X?" подбираем такой X, чтобы примерно в половине случаев ответ был "НЕТ"
        
        let threshold: Int
        
        if rating > 8.5 {
            // Высокий рейтинг - спрашиваем про высокий порог (часто ответ "НЕТ")
            threshold = Int.random(in: 8...9) // 8 или 9
        } else if rating > 7.5 {
            // Выше среднего - разнообразные пороги
            threshold = Int.random(in: 7...9) // 7, 8 или 9
        } else if rating > 6.5 {
            // Средний рейтинг
            threshold = Int.random(in: 6...8) // 6, 7 или 8
        } else {
            // Низкий рейтинг - спрашиваем про низкие пороги (часто ответ "ДА")
            threshold = Int.random(in: 4...6) // 4, 5 или 6
        }
        
        let correctAnswer = rating > Float(threshold)
        let questionText = "Рейтинг этого фильма \nбольше чем \(threshold)?"
        
        return (questionText, correctAnswer)
    }
    
    private func generateLessQuestion(for rating: Float) -> (text: String, correctAnswer: Bool) {
        // Для вопроса "меньше чем X?" подбираем такой X, чтобы примерно в половине случаев ответ был "НЕТ"
        
        let threshold: Int
        
        if rating > 8.5 {
            // Высокий рейтинг - спрашиваем про низкие пороги (ответ всегда "НЕТ")
            threshold = Int.random(in: 5...7) // 5, 6 или 7
        } else if rating > 7.5 {
            // Выше среднего - спрашиваем про средние пороги
            threshold = Int.random(in: 6...8) // 6, 7 или 8
        } else if rating > 6.5 {
            // Средний рейтинг - разнообразные пороги
            threshold = Int.random(in: 7...9) // 7, 8 или 9
        } else {
            // Низкий рейтинг - спрашиваем про высокие пороги (ответ всегда "ДА")
            threshold = Int.random(in: 8...10) // 8, 9 или 10
        }
        
        let correctAnswer = rating < Float(threshold)
        let questionText = "Рейтинг этого фильма \nменьше чем \(threshold)?"
        
        return (questionText, correctAnswer)
    }
    
    // MARK: - Simple Balanced Algorithm (еще один вариант)
    
    private func generateBalancedQuestion(for rating: Float) -> (text: String, correctAnswer: Bool) {
        // Всегда создаем вопросы, где примерно 50% ответов "ДА" и 50% "НЕТ"
        
        let randomType = Int.random(in: 0...3)
        
        switch randomType {
        case 0:
            // Вопрос, где вероятен ответ "ДА"
            let threshold = Int(rating) - Int.random(in: 1...2)
            return ("Рейтинг этого фильма \nбольше чем \(max(4, threshold))?", rating > Float(max(4, threshold)))
            
        case 1:
            // Вопрос, где вероятен ответ "НЕТ"
            let threshold = Int(rating) + Int.random(in: 1...2)
            return ("Рейтинг этого фильма \nбольше чем \(min(10, threshold))?", rating > Float(min(10, threshold)))
            
        case 2:
            // Вопрос "меньше", где вероятен ответ "ДА"
            let threshold = Int(rating) + Int.random(in: 1...2)
            return ("Рейтинг этого фильма \nменьше чем \(min(10, threshold))?", rating < Float(min(10, threshold)))
            
        case 3:
            // Вопрос "меньше", где вероятен ответ "НЕТ"
            let threshold = Int(rating) - Int.random(in: 1...2)
            return ("Рейтинг этого фильма \nменьше чем \(max(4, threshold))?", rating < Float(max(4, threshold)))
            
        default:
            return ("Рейтинг этого фильма \nбольше чем 7?", rating > 7.0)
        }
    }
}

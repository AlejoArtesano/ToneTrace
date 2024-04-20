import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
  var audioManager = AudioManager()
  
  // Флаги состояния игры
  var isGameActive = false
  var isUserInteractionAllowed = false
  
  // Элементы игрового интерфейса
  var score = 0
  var level = 1
  var scoreLabel: SKLabelNode!
  var statusLabel: SKLabelNode!
  var squares = [SKShapeNode]()
  var sequence = [Int]()
  var userSequence = [Int]()

  // Инициализация игры, вызывается при первом показе сцены
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    audioManager.setupAudioPlayers()
    setupInterface()
    setupSquares()
  }
  
  // Настройка элементов пользовательского интерфейса: метки и кнопки.
  func setupInterface() {
    setupScoreLabel()
    setupStatusLabel()
    setupButtons()
  }
  
  // Настройка и инициализация ScoreLabel
  func setupScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: "Arial")
    scoreLabel.fontSize = 24
    scoreLabel.fontColor = SKColor.white
    scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 150)
    scoreLabel.text = "Score: \(score)"
    addChild(scoreLabel)
  }
  
  // Настройка и инициализация statusLabel
  func setupStatusLabel() {
    statusLabel = SKLabelNode(fontNamed: "Arial")
    statusLabel.fontSize = 24
    statusLabel.fontColor = SKColor.white
    statusLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
    statusLabel.text = "Welcome to the Game!"
    addChild(statusLabel)
  }

  // Настройка кнопок управления игрой
  func setupButtons() {
    let startButton = SKLabelNode(fontNamed: "Arial")
    startButton.text = "Begin"
    startButton.fontSize = 24
    startButton.fontColor = SKColor.green
    startButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 150)
    startButton.name = "startButton"
    addChild(startButton)
    
    let endButton = SKLabelNode(fontNamed: "Arial")
    endButton.text = "End"
    endButton.fontSize = 24
    endButton.fontColor = SKColor.red
    endButton.position = CGPoint(x: frame.midX + 100, y: frame.midY - 150)
    endButton.name = "endButton"
    addChild(endButton)
  }
  
  
  // Настройка визуальных элементов (квадратов) для игры
  func setupSquares() {
    let colors = [
      SKColor(red: 1, green: 0.5, blue: 0.5, alpha: 1), // более светлый красный
      SKColor(red: 1, green: 1, blue: 0.5, alpha: 1), // более светлый желтый
      SKColor(red: 0.5, green: 1, blue: 0.5, alpha: 1) // более светлый зеленый
    ]
    let squareSize = CGSize(width: 80, height: 80)
    
    for i in 0..<3 {
      let square = SKShapeNode(rectOf: squareSize, cornerRadius: 12) // Увеличенные скругленные углы
      square.fillColor = colors[i]
      square.position = CGPoint(x: frame.midX + CGFloat(i * 100) - 100, y: frame.midY) // Расширение расстояния между квадратами
      square.name = "square\(i)"
      squares.append(square)
      addChild(square)
    }
  }
  
  // Подсветка квадрата при активации
  func highlightSquare(at index: Int) {
    let highlightAction = SKAction.sequence([
      SKAction.scale(to: 1.2, duration: 0.1),
      SKAction.wait(forDuration: 0.1),
      SKAction.scale(to: 1.0, duration: 0.1)
    ])
    squares[index].run(highlightAction)
  }
  
  
  // Запуск игры
  func startGame() {
    if !isGameActive {
      isGameActive = true
      isUserInteractionAllowed = false  // Предотвращаем взаимодействие в начале игры
      sequence.removeAll()
      userSequence.removeAll()
      
      level = 1  // Начинаем с первого уровня
      score = 0  // Сброс счета
      updateScoreLabel()  // Обновление отображения счета
      
      // Обновляем статус, сообщая о скором начале игры
      updateStatusLabel(text: "Get ready...")
      
      // Добавляем задержку перед началом игры
      let delayAction = SKAction.wait(forDuration: 2.0)  // Пауза в 2 секунды
      let startSequenceAction = SKAction.run { [weak self] in
        guard let self = self else { return }
        self.generateSequence(length: 2 + self.level)  // Установка длины последовательности в зависимости от уровня
        self.showSequence()
        self.updateStatusLabel(text: "Watch the sequence!")
      }
      run(SKAction.sequence([delayAction, startSequenceAction]))
    }
  }
  
  // Окончание игры
  func endGame() {
    isGameActive = false
    isUserInteractionAllowed = false
    sequence.removeAll()
    userSequence.removeAll()
    removeAllActions()
    score = 0
    updateScoreLabel()  // Обновление отображения счета
    level = 1
    updateStatusLabel(text: "Game Over! Press Begin to play again.")
    print("Game has been stopped.")
  }
  
  // Обработка взаимодействия с квадратами
  func handleSquareInteraction(at location: CGPoint) {
    if isGameActive && isUserInteractionAllowed && userSequence.count < sequence.count {
      for (index, square) in squares.enumerated() {
        if square.frame.contains(location) {
          highlightSquare(at: index)
          userSequence.append(index)
          audioManager.playSoundForSquare(index: index)
          checkCompletion()
        }
      }
    }
  }

  // Обработка действий пользователя и обновление счёта
  func handleUserAction(correct: Bool) {
    if correct {
      updateScore(by: 10) // Начисление очков за правильный ответ
    } else {
      updateScore(by: -5) // Списание очков за ошибку
      updateStatusLabel(text: "Wrong sequence! Try again.")
    }
  }
  
  // Проверка завершения ввода последовательности пользователем
  func checkCompletion() {
    if userSequence.count == sequence.count {
      if userSequence == sequence {
        print("User successfully completed the sequence")
        updateStatusLabel(text: "Correct! Get ready for the next sequence...")
        
        updateScore(by: 10)  // Начисление очков за правильный ответ
        level += 1  // Переход на следующий уровень
        
        userSequence.removeAll()  // Очищаем последовательность пользователя для следующего раунда
        
        // Задержка перед генерацией новой последовательности
        let delayAction = SKAction.wait(forDuration: 2.0)
        let sequenceAction = SKAction.run { [weak self] in
          guard let self = self else { return }
          self.generateSequence(length: 2 + self.level)  // Увеличиваем сложность последовательности
          self.showSequence()
          self.updateStatusLabel(text: "Watch the sequence!")
        }
        run(SKAction.sequence([delayAction, sequenceAction]))
      } else {
        updateStatusLabel(text: "Incorrect! Try this level again: \(level)")
        print("User made an error in the sequence")
        updateScore(by: -5)  // Списание очков за ошибку
        
        if level > 1 {
          level -= 1  // Понижаем уровень, если это не первый уровень
        }
        
        userSequence.removeAll()  // Очищаем последовательность пользователя
        
        // Задержка перед повторением того же уровня
        let delayAction = SKAction.wait(forDuration: 2.0)
        let sequenceAction = SKAction.run { [weak self] in
          guard let self = self else { return }
          self.generateSequence(length: 2 + self.level)  // Генерируем ту же сложность
          self.showSequence()
          self.updateStatusLabel(text: "Try again! Watch the sequence!")
        }
        run(SKAction.sequence([delayAction, sequenceAction]))
      }
    }
  }
  
  // Генерирование случайной последовательности для игры
  func generateSequence(length: Int) {
    sequence.removeAll()
    for _ in 0..<length {
      let randomIndex = Int(arc4random_uniform(UInt32(squares.count)))
      sequence.append(randomIndex)
    }
    print("Generated game sequence: \(sequence)")
  }
  
  // Демонстрация сгенерированной последовательности с анимацией и звуком
  func showSequence() {
    updateStatusLabel(text: "Watch the sequence!")
    isUserInteractionAllowed = false  // Блокируем взаимодействие на время демонстрации
    userSequence.removeAll()  // Очищаем последовательность пользователя перед новым раундом
    var delay = 0.0
    for index in sequence {
      let waitAction = SKAction.wait(forDuration: delay)
      let highlightAction = SKAction.run { [weak self] in
        guard let self = self else { return }
        self.highlightSquare(at: index)
        self.audioManager.playSoundForSquare(index: index)
      }
      run(SKAction.sequence([waitAction, highlightAction]))
      delay += 2
    }
    run(SKAction.wait(forDuration: delay)) { [weak self] in
      self?.isUserInteractionAllowed = true  // Разрешаем взаимодействие после паузы
      self?.updateStatusLabel(text: "Your turn!")
    }
  }
  
  // Генерирует и демонстрирует новую последовательность игры
  func generateAndShowSequence() {
    generateSequence(length: 2 + level)  // 3 сигнала на первом уровне
    showSequence()
  }
  
  
  // Изменяет счет на указанное количество очков.
  func updateScore(by points: Int) {
    score += points
    scoreLabel.text = "Score: \(score)" // Обновление текста метки счета
  }
  
  // Обновляет текстовую метку с текущим счетом.
  func updateScoreLabel() {
    scoreLabel.text = "Score: \(score)"
  }
  
  // Обновляет текст статуса во время игры
  func updateStatusLabel(text: String) {
    statusLabel.text = text
  }
  
  
  // Обработка нажатий мыши
  override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    let nodes = self.nodes(at: location)
    
    for node in nodes {
      if let nodeName = node.name {
        switch nodeName {
          case "startButton":
            if !isGameActive {
              startGame()
            }
          case "endButton":
            endGame()
          default:
            handleSquareInteraction(at: location)
        }
      }
    }
  }

}


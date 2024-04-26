import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
  var audioManager = AudioManager()
  var interfaceManager: InterfaceManager!
  
  // Флаги состояния игры
  var isGameActive = false
  var isUserInteractionAllowed = false
  
  // Элементы игрового интерфейса
  var level = 1
  var squares = [SKShapeNode]()
  var sequence = [Int]()
  var userSequence = [Int]()
  
  // Инициализация игры, вызывается при первом показе сцены
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    audioManager.setupAudioPlayers()
    interfaceManager = InterfaceManager(scene: self)  // Создаем InterfaceManager и передаем текущую сцену
    setupSquares()
    setupButtons()
  }
  
  // Настройка кнопок управления игрой
  func setupButtons() {
    // Создаем спрайт для кнопки "Start"
    let startButton = SKShapeNode(rectOf: CGSize(width: 100, height: 44), cornerRadius: 10)
    startButton.fillColor = SKColor.lightGray
    startButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 150)
    startButton.name = "startButton"
    
    let startLabel = SKLabelNode(text: "Start")
    startLabel.fontName = "Arial"
    startLabel.fontSize = 20
    startLabel.fontColor = SKColor.white
    startLabel.verticalAlignmentMode = .center
    startButton.addChild(startLabel)
    startButton.isUserInteractionEnabled = false // Управление через scene
    addChild(startButton)
    
    // Создаем спрайт для кнопки "End"
    let endButton = SKShapeNode(rectOf: CGSize(width: 100, height: 44), cornerRadius: 10)
    endButton.fillColor = SKColor.lightGray
    endButton.position = CGPoint(x: frame.midX + 100, y: frame.midY - 150)
    endButton.name = "endButton"
    
    let endLabel = SKLabelNode(text: "End")
    endLabel.fontName = "Arial"
    endLabel.fontSize = 20
    endLabel.fontColor = SKColor.white
    endLabel.verticalAlignmentMode = .center
    endButton.addChild(endLabel)
    endButton.isUserInteractionEnabled = false // Управление через scene
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
  
  
  func resetGame() {
    isGameActive = false
    isUserInteractionAllowed = false
    sequence.removeAll()
    userSequence.removeAll()
    interfaceManager.score = 0  // Сброс счета
    level = 1
  }
  
  // Запуск игры
  func startGame() {
    resetGame()
    isGameActive = true
    interfaceManager.updateStatusLabel(text: "Get ready...")
    prepareForNewSequence()
  }
  
  // Подготавливает и начинает новую последовательность в игре после задержки.
  func prepareForNewSequence() {
    let delayAction = SKAction.wait(forDuration: 2.0)
    let startSequenceAction = SKAction.run { [weak self] in
      guard let self = self else { return }
      self.generateSequence(length: 2 + self.level)
      self.showSequence()
    }
    run(SKAction.sequence([delayAction, startSequenceAction]))
  }
  
  // Окончание игры
  func endGame() {
    resetGame()
    interfaceManager.updateHighScore(score: interfaceManager.score)
    interfaceManager.updateStatusLabel(text: "Game Over! Press Begin to play again.")
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
      interfaceManager.updateScore(by: 10) // Начисление очков за правильный ответ
    } else {
      interfaceManager.updateScore(by: -5) // Списание очков за ошибку
      interfaceManager.updateStatusLabel(text: "Wrong sequence! Try again.")
    }
  }
  
  // Проверка завершения ввода последовательности пользователем
  func checkCompletion() {
    if userSequence.count == sequence.count {
      if userSequence == sequence {
        print("User successfully completed the sequence")
        interfaceManager.updateStatusLabel(text: "Correct! Get ready for the next sequence...")
        interfaceManager.updateScore(by: 10)  // Начисление очков за правильный ответ
        level += 1  // Переход на следующий уровень
        userSequence.removeAll()  // Очищаем последовательность пользователя для следующего раунда
        
        // Задержка перед генерацией новой последовательности
        let delayAction = SKAction.wait(forDuration: 2.0)
        let sequenceAction = SKAction.run { [weak self] in
          guard let self = self else { return }
          self.generateSequence(length: 2 + self.level)  // Увеличиваем сложность последовательности
          self.showSequence()
          self.interfaceManager.updateStatusLabel(text: "Watch the sequence!")
        }
        run(SKAction.sequence([delayAction, sequenceAction]))
      } else {
        interfaceManager.updateStatusLabel(text: "Incorrect! Try this level again: \(level)")
        print("User made an error in the sequence")
        interfaceManager.updateScore(by: -5)  // Списание очков за ошибку
        
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
          self.interfaceManager.updateStatusLabel(text: "Try again! Watch the sequence!")
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
    interfaceManager.updateStatusLabel(text: "Watch the sequence!")
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
      self?.interfaceManager.updateStatusLabel(text: "Your turn!")
    }
  }
  
  // Генерирует и демонстрирует новую последовательность игры
  func generateAndShowSequence() {
    generateSequence(length: 2 + level)  // 3 сигнала на первом уровне
    showSequence()
  }
  
  
  // Обрабатывает действия для кнопок в игре.
  func handleButtonAction(named nodeName: String) {
    if nodeName == "startButton" {
      startGame()
    } else if nodeName == "endButton" {
      endGame()
    }
  }
  
  // Обработка нажатий мыши
  override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    let nodes = self.nodes(at: location)
    
    // Обработка нажатий на кнопки
    for node in nodes where node.name == "startButton" || node.name == "endButton" {
      node.run(SKAction.scale(to: 0.9, duration: 0.1))
      handleButtonAction(named: node.name!)
    }
    
    // Обработка нажатий на квадраты
    handleSquareInteraction(at: location)
  }
  
  override func mouseUp(with event: NSEvent) {
    let location = event.location(in: self)
    let nodes = self.nodes(at: location)
    
    // Обработка отпускания кнопок
    for node in nodes where node.name == "startButton" || node.name == "endButton" {
      node.run(SKAction.scale(to: 1.0, duration: 0.1))
    }
  }
  
}

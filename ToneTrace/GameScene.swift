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
    setupScene()
  }
  
  // Настраивает начальные элементы сцены при первом показе.
  private func setupScene() {
    backgroundColor = SKColor.black
    audioManager.setupAudioPlayers()
    interfaceManager = InterfaceManager(scene: self)
    setupSquares()
    setupButtons()
  }
  
  // Создает кнопку для управления игрой
  private func createButton(withTitle title: String, position: CGPoint, name: String) -> SKShapeNode {
    let button = SKShapeNode(rectOf: CGSize(width: 100, height: 44), cornerRadius: 10)
    button.fillColor = SKColor.lightGray
    button.position = position
    button.name = name
    
    let label = SKLabelNode(text: title)
    label.fontName = "Arial"
    label.fontSize = 20
    label.fontColor = SKColor.white
    label.verticalAlignmentMode = .center
    button.addChild(label)
    return button
  }
  
  // Настройка кнопок управления игрой
  func setupButtons() {
    let startButton = createButton(withTitle: "Start", position: CGPoint(x: frame.midX - 100, y: frame.midY - 150), name: "startButton")
    addChild(startButton)
    
    let endButton = createButton(withTitle: "End", position: CGPoint(x: frame.midX + 100, y: frame.midY - 150), name: "endButton")
    addChild(endButton)
  }
  
  // Создает визуальный элемент игры в виде квадрата.
  private func createSquare(color: SKColor, size: CGSize, position: CGPoint, name: String) -> SKShapeNode {
    let square = SKShapeNode(rectOf: size, cornerRadius: 12)
    square.fillColor = color
    square.position = position
    square.name = name
    return square
  }
  
  // Настройка визуальных элементов (квадратов) для игры
  func setupSquares() {
    let colors = [
      SKColor(red: 1, green: 0.5, blue: 0.5, alpha: 1),  // более светлый красный
      SKColor(red: 1, green: 1, blue: 0.5, alpha: 1),  // более светлый желтый
      SKColor(red: 0.5, green: 1, blue: 0.5, alpha: 1) // более светлый зеленый
    ]
    let squareSize = CGSize(width: 80, height: 80)
    for (index, color) in colors.enumerated() {
      let position = CGPoint(x: frame.midX + CGFloat(index * 100) - 100, y: frame.midY)
      let square = createSquare(color: color, size: squareSize, position: position, name: "square\(index)")
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
  
  // Сброс игры
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
  private func handleSquareInteraction(node: SKNode, at location: CGPoint, isMouseDown: Bool) {
    if isMouseDown && isUserInteractionAllowed {
      if let nodeName = node.name, let squareIndex = Int(nodeName.filter { "0"..."9" ~= $0 }) {
        highlightSquare(at: squareIndex) // Подсветка квадрата при активации
        userSequence.append(squareIndex) // Добавление номера квадрата в последовательность пользователя
        audioManager.playSoundForSquare(index: squareIndex) // Воспроизведение звука
        checkCompletion() // Проверка завершения ввода последовательности
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
    generateSequence(length: 2 + level)
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
    processInput(at: location, with: event, isMouseDown: true)
  }
  
  // Обработка отпускания кнопки мыши
  override func mouseUp(with event: NSEvent) {
    let location = event.location(in: self)
    processInput(at: location, with: event, isMouseDown: false)
  }
  
  // Общий метод для обработки входных событий, чтобы избежать дублирования кода
  private func processInput(at location: CGPoint, with event: NSEvent, isMouseDown: Bool) {
    let nodes = self.nodes(at: location)
    
    for node in nodes {
      if let nodeName = node.name, nodeName == "startButton" || nodeName == "endButton" {
        handleButtonInteraction(node: node, isMouseDown: isMouseDown)
      } else if node.name?.starts(with: "square") == true {
        handleSquareInteraction(node: node, at: location, isMouseDown: isMouseDown)
      }
    }
  }
  
  // Обрабатывает взаимодействия с кнопками
  private func handleButtonInteraction(node: SKNode, isMouseDown: Bool) {
    if isMouseDown {
      node.run(SKAction.scale(to: 0.9, duration: 0.1)) // Анимация нажатия кнопки
      handleButtonAction(named: node.name!) // Вызывает действие, связанное с кнопкой
    } else {
      node.run(SKAction.scale(to: 1.0, duration: 0.1)) // Анимация отпускания кнопки
    }
  }
  
}

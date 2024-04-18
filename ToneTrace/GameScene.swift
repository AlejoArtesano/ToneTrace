import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
  // Флаги состояния игры
  var isGameActive = false
  var isUserInteractionAllowed = false
  
  // Элементы игрового интерфейса
  var squares = [SKShapeNode]()
  var sequence = [Int]()
  var userSequence = [Int]()
  
  // Аудио плееры для воспроизведения звуков
  var audioPlayer1: AVAudioPlayer?
  var audioPlayer2: AVAudioPlayer?
  var audioPlayer3: AVAudioPlayer?
  
  // Инициализация игры, вызывается при первом показе сцены
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    setupButtons()
    setupAudioPlayers()
    setupSquares()
  }
  
  // Настройка кнопок управления игрой
  func setupButtons() {
    let startButton = SKLabelNode(fontNamed: "Arial")
    startButton.text = "Begin"
    startButton.fontSize = 24
    startButton.fontColor = SKColor.green
    startButton.position = CGPoint(x: frame.midX, y: frame.midY + 100)
    startButton.name = "startButton"
    addChild(startButton)
    
    let endButton = SKLabelNode(fontNamed: "Arial")
    endButton.text = "End"
    endButton.fontSize = 24
    endButton.fontColor = SKColor.red
    endButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
    endButton.name = "endButton"
    addChild(endButton)
  }
  
  // Создание и настройка аудио плееров для воспроизведения звуков
  func setupAudioPlayers() {
    audioPlayer1 = createAudioPlayer(fileName: "guitar_a2_A.m4a")
    audioPlayer2 = createAudioPlayer(fileName: "guitar_b2_B.m4a")
    audioPlayer3 = createAudioPlayer(fileName: "guitar_f2-low_F.m4a")
  }
  
  // Создание аудио плеера из файла
  private func createAudioPlayer(fileName: String) -> AVAudioPlayer? {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
      print("Failed to find the file \(fileName)")
      return nil
    }
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
      return player
    } catch {
      print("Failed to create audio player: \(error)")
      return nil
    }
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
  
  // Генерация случайной последовательности для игры
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
    isUserInteractionAllowed = false  // Блокируем взаимодействие на время демонстрации
    userSequence.removeAll()  // Очищаем последовательность пользователя перед новым раундом
    var delay = 0.0
    for index in sequence {
      let waitAction = SKAction.wait(forDuration: delay)
      let highlightAction = SKAction.run { [weak self] in
        guard let self = self else { return }
        self.highlightSquare(at: index)
        self.playSoundForSquare(index: index)
      }
      run(SKAction.sequence([waitAction, highlightAction]))
      delay += 2  // Увеличиваем задержку, предполагая, что каждый звук длится примерно 0.5 секунды
    }
    run(SKAction.wait(forDuration: delay)) { [weak self] in
      self?.isUserInteractionAllowed = true  // Разрешаем взаимодействие после паузы
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
  
  // Запуск игры
  func startGame() {
    if !isGameActive {
      isGameActive = true
      isUserInteractionAllowed = false  // Предотвращаем взаимодействие в начале игры
      sequence.removeAll()
      userSequence.removeAll()
      generateSequence(length: 3)
      showSequence()
      print("Game started")
    }
  }
  
  // Окончание игры
  func endGame() {
    isGameActive = false
    isUserInteractionAllowed = false
    sequence.removeAll()
    userSequence.removeAll()
    removeAllActions()
    print("Game has been stopped.")
  }
  
  // Воспроизведение звука для квадрата
  func playSoundForSquare(index: Int) {
    print("Attempting to play sound for square at index \(index)")
    let player: AVAudioPlayer?
    switch index {
      case 0:
        player = audioPlayer1
      case 1:
        player = audioPlayer2
      case 2:
        player = audioPlayer3
      default:
        print("No audio player available for index \(index)")
        return
    }
    
    // Проверяем, воспроизводится ли звук, если да, останавливаем его и начинаем заново
    if player?.isPlaying == true {
      player?.stop()
      player?.currentTime = 0  // Сбрасываем время воспроизведения на начало
    }
    player?.play()
  }
  
  // Обработка взаимодействия с квадратами
  func handleSquareInteraction(at location: CGPoint) {
    if isGameActive && isUserInteractionAllowed && userSequence.count < sequence.count {
      for (index, square) in squares.enumerated() {
        if square.frame.contains(location) {
          highlightSquare(at: index)
          userSequence.append(index)
          playSoundForSquare(index: index)
          checkCompletion()
        }
      }
    }
  }
  
  // Проверка завершения ввода последовательности пользователем
  func checkCompletion() {
    if userSequence.count == sequence.count {
      if userSequence == sequence {
        print("User successfully completed the sequence")
        // Очищаем последовательность пользователя для следующего раунда
        userSequence.removeAll()
        // Подготовка к следующему уровню с задержкой
        let delayAction = SKAction.wait(forDuration: 3.0)  // Задержка в 3 секунды
        let sequenceAction = SKAction.run { [weak self] in
          guard let self = self else { return }
          // Увеличиваем сложность
          self.generateSequence(length: self.sequence.count + 1)
          self.showSequence()
        }
        run(SKAction.sequence([delayAction, sequenceAction]))
      } else {
        print("User made an error in the sequence")
        endGame()  // Остановка игры в случае ошибки
      }
    }
  }

}


import SpriteKit
import GameplayKit
import AVFoundation


class GameScene: SKScene {
    var squares = [SKShapeNode]()
    var sequence = [Int]()
    var userSequence = [Int]()

    var audioPlayer1: AVAudioPlayer?
    var audioPlayer2: AVAudioPlayer?
    var audioPlayer3: AVAudioPlayer?
  
    override func didMove(to view: SKView) {
      backgroundColor = SKColor.black
      setupAudioPlayers()
      setupSquares()
      generateSequence(length: 3)  // Генерируем последовательность из 3 миганий
      showSequence()  // Показываем её пользователю
      
    }
    
  
  func setupAudioPlayers() {
    audioPlayer1 = createAudioPlayer(fileName: "guitar_a2_A.m4a")
    audioPlayer2 = createAudioPlayer(fileName: "guitar_b2_B.m4a")
    audioPlayer3 = createAudioPlayer(fileName: "guitar_f2-low_F.m4a")
  }
  
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
  
  func generateSequence(length: Int) {
    sequence.removeAll()
    for _ in 0..<length {
      let randomIndex = Int(arc4random_uniform(UInt32(squares.count)))
      sequence.append(randomIndex)
      
    }
    print("Generated game sequence: \(sequence)")
  }

  func showSequence() {
    var delay = 0.0
    for index in sequence {
      let waitAction = SKAction.wait(forDuration: delay)
      let highlightAction = SKAction.run { [weak self] in
        self?.highlightSquare(at: index)
      }
      run(SKAction.sequence([waitAction, highlightAction]))
      delay += 1.0  // Задержка между миганиями
    }
  }

  
  func highlightSquare(at index: Int) {
    let highlightAction = SKAction.sequence([
      SKAction.scale(to: 1.2, duration: 0.1),
      SKAction.wait(forDuration: 0.1),
      SKAction.scale(to: 1.0, duration: 0.1)
    ])
    squares[index].run(highlightAction)
  }
  
  
  override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    
    if userSequence.count < sequence.count {  // Проверяем, не превышает ли количество нажатий длину последовательности
      for (index, square) in squares.enumerated() {
        if square.frame.contains(location) {
          highlightSquare(at: index)
          userSequence.append(index)
          playSoundForSquare(index: index)
          checkCompletion()  // Проверяем, завершил ли пользователь ввод
        }
      }
    }
  }
  
  
  func playSoundForSquare(index: Int) {
    print("Attempting to play sound for square at index \(index)")
    switch index {
      case 0:
        audioPlayer1?.play()
      case 1:
        audioPlayer2?.play()
      case 2:
        audioPlayer3?.play()
      default:
        print("No audio player available for index \(index)")
    }
  }

  
  func checkCompletion() {
    if userSequence.count == sequence.count {
      print("Generated user sequence: \(userSequence)")
      print("User has completed entering the sequence")

    }
  }
  
}

import SpriteKit

class InterfaceManager {
  weak var scene: SKScene?  // Слабая ссылка, чтобы избежать циклических зависимостей
  var scoreLabel: SKLabelNode!
  var statusLabel: SKLabelNode!
  var score: Int = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  init(scene: SKScene) {
    self.scene = scene
    setupScoreLabel()
    setupStatusLabel()
    setupGameArea()
  }
  
  private func setupScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: "Arial")
    scoreLabel.fontSize = 24
    scoreLabel.fontColor = SKColor.white
    scoreLabel.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY - 150)
    scoreLabel.text = "Score: \(score)"
    scene?.addChild(scoreLabel)
  }
  
  // Настройка и инициализация statusLabel
  func setupStatusLabel() {
    statusLabel = SKLabelNode(fontNamed: "Arial")
    statusLabel.fontSize = 24
    statusLabel.fontColor = SKColor.white
    statusLabel.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY + 100)
    statusLabel.text = "Welcome to the Game!"
    scene?.addChild(statusLabel)
  }
  
  private func setupGameArea() {
  let borderWidth: CGFloat = 1  // Тонкая рамка
  let padding: CGFloat = 50  // Отступы от краев окна
  
  // Рассчитываем размеры рамки
  let totalWidth: CGFloat = 330  // Ширина руками
  let totalHeight = scene!.frame.height - padding * 2  // Высота рамки с учетом отступов
  
  let gameAreaRect = CGRect(x: scene!.frame.midX - totalWidth / 2, y: scene!.frame.midY - totalHeight / 2, width: totalWidth, height: totalHeight)
  let gameArea = SKShapeNode(rect: gameAreaRect, cornerRadius: 20)
  gameArea.strokeColor = SKColor.white
  gameArea.lineWidth = borderWidth
  gameArea.zPosition = -1  // Позиция за всеми другими элементами
  scene?.addChild(gameArea)
}
  
  
  
  // Изменяет счет на указанное количество очков.
  func updateScore(by points: Int) {
    score += points
    //    scoreLabel.text = "Score: \(score)" // Обновление текста метки счета
  }
  
  // Обновляет текстовую метку с текущим счетом.
  func updateScoreLabel() {
    scoreLabel.text = "Score: \(score)"
  }
  
  // Обновляет текст статуса во время игры
  func updateStatusLabel(text: String) {
    statusLabel.text = text
  }
}

import SpriteKit

class InterfaceManager {
  weak var scene: SKScene?  // Слабая ссылка, чтобы избежать циклических зависимостей
  var scoreLabel: SKLabelNode!
  var highScoreLabel: SKLabelNode!
  var statusLabel: SKLabelNode!
  var gameAreaRect: CGRect?  // Свойство для хранения размеров и позиции игровой области
  var score: Int = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
    
  init(scene: SKScene) {
    self.scene = scene
    setupGameArea()
    setupScoreLabel()
    setupHighScoreLabel()
    setupStatusLabel()
  }
  
  // Настройка и инициализация зоны игры
  private func setupGameArea() {
    let borderWidth: CGFloat = 1
    let padding: CGFloat = 50
    let totalWidth: CGFloat = 330
    let totalHeight = scene!.frame.height - padding * 2
    
    gameAreaRect = CGRect(x: scene!.frame.midX - totalWidth / 2, y: scene!.frame.midY - totalHeight / 2, width: totalWidth, height: totalHeight)
    let gameArea = SKShapeNode(rect: gameAreaRect!, cornerRadius: 20)
    gameArea.strokeColor = SKColor.white
    gameArea.lineWidth = borderWidth
    gameArea.zPosition = -1
    scene?.addChild(gameArea)
  }
  
  // Настройка и инициализация ScoreLabel
  func setupScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: "Arial")
    scoreLabel.fontSize = 22
    scoreLabel.fontColor = SKColor.white
    scoreLabel.text = "Score: \(score)"
    let xOffset: CGFloat = 57  // Отступ от левой стороны
    let yOffset: CGFloat = 10  // Отступ от верхней стороны
    if let gameAreaRect = gameAreaRect {
      scoreLabel.position = CGPoint(x: gameAreaRect.minX + xOffset, y: gameAreaRect.maxY - scoreLabel.frame.size.height - yOffset)
    }
    scene?.addChild(scoreLabel)
  }
  

  // Настройка и инициализация HighScoreLabel
  private func setupHighScoreLabel() {
    highScoreLabel = SKLabelNode(fontNamed: "Arial")
    highScoreLabel.fontSize = 22
    highScoreLabel.fontColor = SKColor.white
    highScoreLabel.text = "High: 00"
    let xOffset: CGFloat = 273  // Отступ от левой стороны
    let yOffset: CGFloat = 10  // Отступ от верхней стороны
    if let gameAreaRect = gameAreaRect {
      highScoreLabel.position = CGPoint(x: gameAreaRect.minX + xOffset, y: gameAreaRect.maxY - scoreLabel.frame.size.height - yOffset)
    }
    scene?.addChild(highScoreLabel)
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

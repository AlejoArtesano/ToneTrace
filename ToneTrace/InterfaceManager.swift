import SpriteKit

weak var scene: SKScene?

// Константы для настройки интерфейса
private struct Constants {
  static let labelFontSize: CGFloat = 22
  static let labelFontColor = SKColor.white
  static let scoreLabelXOffset: CGFloat = 57
  static let scoreLabelYOffset: CGFloat = 25
  static let highScoreLabelXOffset: CGFloat = 273
  static let highScoreLabelYOffset: CGFloat = 25
  static let statusLabelFontSize: CGFloat = 24
  static let statusLabelYOffset: CGFloat = 100
  static let gameAreaBorderWidth: CGFloat = 1
  static let padding: CGFloat = 50
  static let totalWidth: CGFloat = 330
  static let cornerRadius: CGFloat = 20
}

class InterfaceManager {
  weak var scene: SKScene?
  var scoreLabel: SKLabelNode!
  var highScoreLabel: SKLabelNode!
  var statusLabel: SKLabelNode!
  var gameAreaRect: CGRect?
  
  var score: Int = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  var highScore: Int = 0 {
    didSet {
      highScoreLabel.text = "High: \(highScore)"
    }
  }
  
  init(scene: SKScene) {
    self.scene = scene
    setupGameArea()
    setupScoreLabel()
    setupHighScoreLabel()
    setupStatusLabel()
  }
  
  // Определение геометрии игровой зоны
  private func configureGameAreaGeometry() -> CGRect {
    let totalHeight = scene!.frame.height - Constants.padding * 2
    return CGRect(x: scene!.frame.midX - Constants.totalWidth / 2, y: scene!.frame.midY - totalHeight / 2, width: Constants.totalWidth, height: totalHeight)
  }
  
  // Настройка и инициализация зоны игры
  private func setupGameArea() {
    gameAreaRect = configureGameAreaGeometry()
    let gameArea = SKShapeNode(rect: gameAreaRect!, cornerRadius: Constants.cornerRadius)
    gameArea.strokeColor = Constants.labelFontColor
    gameArea.lineWidth = Constants.gameAreaBorderWidth
    gameArea.zPosition = -1
    scene?.addChild(gameArea)
  }
  
  // Настройка и инициализация ScoreLabel
  func setupScoreLabel() {
    let position = CGPoint(
      x: gameAreaRect!.minX + Constants.scoreLabelXOffset,
      y: gameAreaRect!.maxY - Constants.scoreLabelYOffset
    )
    scoreLabel = createLabelNode(text: "Score: \(score)", fontSize: Constants.labelFontSize, fontColor: Constants.labelFontColor, position: position)
    scene?.addChild(scoreLabel)
  }
  
  // Настройка и инициализация HighScoreLabel
  func setupHighScoreLabel() {
    let position = CGPoint(
      x: gameAreaRect!.minX + Constants.highScoreLabelXOffset,
      y: gameAreaRect!.maxY - Constants.highScoreLabelYOffset
    )
    highScoreLabel = createLabelNode(text: "High: \(highScore)", fontSize: Constants.labelFontSize, fontColor: Constants.labelFontColor, position: position)
    scene?.addChild(highScoreLabel)
    loadHighScore()
  }
  
  // Метод для создания меток
  private func createLabelNode(text: String, fontSize: CGFloat, fontColor: SKColor, position: CGPoint) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: "Arial")
    label.fontSize = fontSize
    label.fontColor = fontColor
    label.text = text
    label.position = position
    return label
  }
  
  // Настройка и инициализация statusLabel
  func setupStatusLabel() {
    let position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY + Constants.statusLabelYOffset)
    statusLabel = createLabelNode(text: "Welcome to the Game!", fontSize: Constants.statusLabelFontSize, fontColor: Constants.labelFontColor, position: position)
    scene?.addChild(statusLabel)
  }
  
  // Изменяет счет на указанное количество очков
  func updateScore(by points: Int) {
    score += points
  }
  
  // Обновляет текстовую метку с текущим счетом
  func updateScoreLabel() {
    scoreLabel.text = "Score: \(score)"
  }
  
  // Обновляет текст статуса во время игры
  func updateStatusLabel(text: String) {
    statusLabel.text = text
  }
  
  // Загружает рекордный счет из UserDefaults
  func loadHighScore() {
    highScore = UserDefaults.standard.integer(forKey: "highScore")
  }
  
  // Обновляет и сохраняет рекордный счет, если текущий счет выше рекорда
  func updateHighScore(score: Int) {
    if score > highScore {
      highScore = score
      UserDefaults.standard.set(highScore, forKey: "highScore")
    }
  }
}

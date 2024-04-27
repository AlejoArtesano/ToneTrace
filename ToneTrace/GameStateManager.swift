import SpriteKit

class GameStateManager {
  enum State {
    case waitingToStart
    case active
    case gameOver
  }
  
  var currentState: State = .waitingToStart
  weak var gameScene: GameScene? // Слабая ссылка для предотвращения циклических зависимостей
  
  init(gameScene: GameScene) {
    self.gameScene = gameScene
  }
  
  // Запуск игры
  func startGame() {
    resetGame()
    currentState = .active
    gameScene?.interfaceManager.updateStatusLabel(text: "Get ready...")
    gameScene?.prepareForNewSequence()
  }
  
  // Окончание игры
  func endGame() {
    currentState = .gameOver
    resetGame()
    gameScene?.interfaceManager.updateStatusLabel(text: "Game Over! Press Begin to play again.")
  }

  // Сброс игры
  func resetGame() {
    gameScene?.isGameActive = false
    gameScene?.isUserInteractionAllowed = false
    gameScene?.sequence.removeAll()
    gameScene?.userSequence.removeAll()
    gameScene?.interfaceManager.score = 0
    gameScene?.level = 1
    gameScene?.interfaceManager.updateStatusLabel(text: "Game reset! Ready to start new game.")
  }

}

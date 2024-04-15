import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var squares = [SKShapeNode]()
    
    override func didMove(to view: SKView) {
      backgroundColor = SKColor.black
      setupSquares()
      
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
    
    for (index, square) in squares.enumerated() {
      if square.frame.contains(location) {
        highlightSquare(at: index)

      }
    }
  }
  
}

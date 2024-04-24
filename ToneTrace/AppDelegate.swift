import Cocoa
import SpriteKit

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  var skView: SKView!
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Создаем окно
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false)
    window.center()
    window.title = "ToneTrace Game"
    
    // Создаем SKView
    skView = SKView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    window.contentView = skView
    
    // Загружаем и отображаем GameScene
    let scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)
        
    window.makeKeyAndOrderFront(nil)
  }
}


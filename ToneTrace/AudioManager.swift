import AVFoundation

class AudioManager {
  var audioPlayers = [AVAudioPlayer?](repeating: nil, count: 3)
  let soundFileNames = ["guitar_a2_A.m4a", "guitar_b2_B.m4a", "guitar_f2-low_F.m4a"]
  
  func setupAudioPlayers() {
    for (index, fileName) in soundFileNames.enumerated() {
      audioPlayers[index] = createAudioPlayer(fileName: fileName)
    }
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
  
  func playSoundForSquare(index: Int) {
    guard let player = audioPlayers[index] else {
      print("Audio player not initialized for index \(index)")
      return
    }
    if player.isPlaying {
      player.stop()
    }
    player.currentTime = 0
    player.play()
  }
}

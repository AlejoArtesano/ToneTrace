import AVFoundation

class AudioManager {
  // Аудио плееры для воспроизведения звуков
  var audioPlayer1: AVAudioPlayer?
  var audioPlayer2: AVAudioPlayer?
  var audioPlayer3: AVAudioPlayer?
  
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
  
  // Воспроизведение звука для квадрата
  func playSoundForSquare(index: Int) {
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
    if let player = player {
      if player.isPlaying {
        player.stop()
      }
      player.currentTime = 0
      player.play()
      print("Playing sound for index \(index)")
    } else {
      print("Audio player not initialized for index \(index)")
    }
  }
}

import UIKit
import AVFoundation

struct Music {
    let name: String
    let artist: String
    let fileNum: Int
}

class ViewController: UIViewController {
    
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicArtist: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonPrev: UIButton!
    @IBOutlet weak var totalDuration: UILabel!
    
    var audioPlayer: AVAudioPlayer?
    
    let musicList: [Music] = [
        Music(name: "Motivate Me", artist: "Mixaund", fileNum: 1),
        Music(name: "Sleeping Boy Under a Starry Night", artist: "FSM Team & < e s c p >", fileNum: 2),
        Music(name: "EGLAR", artist: "Alex-Productions", fileNum: 3),
        Music(name: "Azure Sky", artist: "Spiring", fileNum: 4),
        Music(name: "Happy Days", artist: "FSM Team", fileNum: 5),
        Music(name: "Stay Positive", artist: "Micaund", fileNum: 6),
        Music(name: "Never Ending", artist: "Spiring", fileNum: 7),
        Music(name: "Rise", artist: "Corporate Music Zone", fileNum: 8),
        Music(name: "Summer Echoes", artist: "Corporate Music Zone", fileNum: 9),
        Music(name: "December 25th with you", artist: "Alex productions", fileNum: 10)
    ]
    
    var currentIndex = 0
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let music = musicList[currentIndex]
        musicName.text = music.name
        musicArtist.text = music.artist
        musicImage.image = UIImage(named: "\(music.fileNum)")
        
        if let url = Bundle.main.url(forResource: "\(music.fileNum)", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                let duration = audioPlayer?.duration ?? 0
                totalDuration.text = formatTime(duration)
            } catch {
                print("Ошибка загрузки файла: \(error.localizedDescription)")
            }
        } else {
            print("Файл \(music.fileNum).mp3 не найден в бандле!")
        }
        
        buttonPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        isPlaying = false
    }
    
    func playCurrentMusic() {
        let music = musicList[currentIndex]

        musicName.text = music.name
        musicArtist.text = music.artist
        musicImage.image = UIImage(named: "\(music.fileNum)")

        if let url = Bundle.main.url(forResource: "\(music.fileNum)", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                
                let duration = audioPlayer?.duration ?? 0
                totalDuration.text = formatTime(duration)
            } catch {
                print("Ошибка воспроизведения: \(error.localizedDescription)")
            }
        } else {
            print("Файл \(music.fileNum).mp3 не найден в бандле!")
        }
        
        isPlaying = true
        buttonPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func playPauseMusic(_ sender: UIButton){
        if isPlaying {
            audioPlayer?.pause()
            buttonPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
        } else {
            audioPlayer?.play()
            buttonPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            isPlaying = true
        }
    }
    
    @IBAction func nextTap(_ sender: UIButton){
        currentIndex = (currentIndex + 1) % musicList.count
        playCurrentMusic()
    }
    
    @IBAction func prevTap(_ sender: UIButton){
        currentIndex = (currentIndex - 1 + musicList.count) % musicList.count
        playCurrentMusic()
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nextTap(buttonNext)
        }
    }
}

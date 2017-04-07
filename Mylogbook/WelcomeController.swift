
import AVFoundation
import AVKit
import UIKit

class WelcomeController: UIViewController {
 
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupVideo()
    }
    
    // MARK: Video
    
    func setupVideo() {
        let path = Bundle.main.path(forResource: "intro", ofType: "mp4")!
        
        let url = URL(fileURLWithPath: path)
        
        let asset = AVAsset(url: url)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 84)
        
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
}

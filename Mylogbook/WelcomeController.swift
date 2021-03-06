
import AVFoundation
import AVKit
import UIKit

class WelcomeController: UIViewController {
 
    var player: AVPlayer!
    
    // MARK: Outlets
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupVideo()

        signUpButton.restyle(.shadow)
        logInButton.restyle(.shadow)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
    }
    
    // MARK: Video
    
    func setupVideo() {
        let path = Bundle.main.path(forResource: "intro", ofType: "mp4")!
        
        let url = URL(fileURLWithPath: path)
        
        let asset = AVAsset(url: url)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 82)
        
        view.layer.addSublayer(playerLayer)
    }
}

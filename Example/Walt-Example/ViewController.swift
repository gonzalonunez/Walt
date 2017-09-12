//
//  ViewController.swift
//  Walt-Example
//
//  Created by Gonzalo Nunez on 9/11/17.
//  Copyright © 2017 Zenun Software. All rights reserved.
//

import AVFoundation
import Walt

class ViewController: UIViewController {
  
  var player: AVPlayer!
  @IBOutlet weak var playButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Loop the video twice. 2 seconds fits two loops of 1 second each.
    let options = MovieWritingOptions(loopDuration: 1.0, duration: Int(2.0))
    
    playButton.isEnabled = false
    try! Walt.writeMovie(
      with: images(),
      options: options) { fileUrl, data in
        self.player = AVPlayer(url: fileUrl)
        let playerLayer = AVPlayerLayer(player: self.player)
      
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.frame = self.view.bounds
      
        self.view.layer.insertSublayer(playerLayer, at: 0)
        self.player.play()
        self.playButton.isEnabled = true
    }
  }
  
  // MARK: Actions
  
  @IBAction func handlePlayButton(_ sender: Any) {
    self.player.seek(to: kCMTimeZero)
    self.player.play()
  }
  
  // MARK: Helpers
  
  private func images() -> [UIImage] {
    return ["😁","😄","😆","😂","🤣"].map { emoji -> UIImage in
      let bounds = AVMakeRect(aspectRatio: CGSize(width: 48, height: 48).rounded(to: 16),
                              insideRect: CGRect(origin: .zero, size: CGSize(width: 1720, height: 1980)))
      let size = bounds.size
      return UIGraphicsImageRenderer(size: size).image { context in
        let font = UIFont.systemFont(ofSize: 120*UIScreen.main.scale)
        let attributed = NSAttributedString(string: emoji, attributes: [NSFontAttributeName: font])
        attributed.draw(at: CGPoint(x:(size.width-attributed.size().width)/2, y:(size.height-attributed.size().height)/2))
      }
    }
  }
}

// MARK: Roundable

protocol Roundable {
  associatedtype RoundableData
  func rounded(to r: RoundableData) -> Self
}

extension CGFloat: Roundable {
  typealias RoundableData = CGFloat
  
  func rounded(to r: RoundableData) -> CGFloat {
    return r * floor((self/r)+0.5)
  }
}

extension CGSize: Roundable {
  typealias RoundableData = CGFloat
  
  func rounded(to r: RoundableData) -> CGSize {
    return CGSize(width: width.rounded(to: r), height: height.rounded(to: r))
  }
}

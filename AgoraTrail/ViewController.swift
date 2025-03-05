//
//  ViewController.swift
//  AgoraTrail
//
//  Created by Dheeraj Pj on 05/03/25.
//

import UIKit
import AgoraRtcKit

class ViewController: UIViewController {
    
    
    @IBAction func startVideoCallButtonAction(_ sender: Any) {
        print("starting video call")
        gotoVideoCallViewController()
    }
    
    
    // Add this line to add the agoraKit variable
    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func gotoVideoCallViewController() {
        DispatchQueue.main.async{ [self] in
            if let videoCallVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoCallViewController") as? VideoChatViewController {
                present(videoCallVc, animated: false)
            }
        }
    }
}

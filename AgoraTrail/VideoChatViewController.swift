//
//  VideoChatViewController.swift
//  AgoraTrail
//
//  Created by Dheeraj Pj on 05/03/25.
//

import Foundation


import UIKit
import AgoraRtcKit

class VideoChatViewController: UIViewController {
    
    @IBOutlet weak var localVideoView: UIView!
    
    @IBOutlet weak var remoteVideoView: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    @IBAction func endCallButtonAction(_ sender: Any) {
        print("End call button clicked")
        dismiss(animated: true)
    }
    
    var agoraKit: AgoraRtcEngineKit?
    
    var appId = "cfe77bf38826491a9944627428d4b030"
    var primaryCert = "e71de214073b48d08e4eb0833cdd48c1"
    var channelName = "dheerajTrailChannel"
    var channelToken = "007eJxTYLi7VLNmx/rv8TG/D/2488lm0ZffZ790bzG6zCKYomL1waVUgSE5LdXcPCnN2MLCyMzE0jDR0tLExMzI3MTIIsUkycDY4MCn4+kNgYwMDcc1WRgZIBDEF2ZIyUhNLUrMCilKzMxxzkjMy0vNYWAAANPCKP8="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAndJoinChannel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endVideoCall()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        localVideoView.layer.shadowColor = UIColor.black.cgColor
        localVideoView.layer.shadowOpacity = 0.3
        localVideoView.layer.shadowOffset = CGSize(width: 5, height: 5)
        localVideoView.layer.shadowRadius = 8
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async{ [self] in
            activityIndicatorView.isHidden = true
            label.isHidden = true
        }
    }
}

// agora code flow
extension VideoChatViewController: AgoraRtcEngineDelegate {
    func initializeAndJoinChannel() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setClientRole(.broadcaster)
        agoraKit?.enableVideo()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localVideoView
        agoraKit?.setupLocalVideo(videoCanvas)
        
        agoraKit?.joinChannel(byToken: channelToken, channelId: channelName, info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            print("got the channel: \(channel), uid: \(uid), elapsed: \(elapsed)")
            self.hideActivityIndicator()
        })
    }
    
    // This callback is triggered when a remote host joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("the new connection uid: \(uid)")
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteVideoView
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("the other user ended the session")
        switch reason {
        case .quit:
            print("User \(uid) left the session manually.")
        case .dropped:
            print("User \(uid) disconnected due to network issues.")
        case .becomeAudience:
            print("User \(uid) switched to audience mode.")
        @unknown default:
            print("User \(uid) went offline for an unknown reason.")
        }
        
        let alertVC = UIAlertController(title: "The Other user left the call", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel) { _ in self.dismiss(animated: true) })
        DispatchQueue.main.async {
            self.present(alertVC, animated: true)
        }
    }
    
    func endVideoCall() {
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
}

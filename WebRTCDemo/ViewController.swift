//
//  ViewController.swift
//  WebRTCDemo
//
//  Created by Hydeguo on 23/01/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit
import Starscream
import WebRTC

class ViewController: UIViewController,OMGRTCClientDelegate,RTCEAGLVideoViewDelegate {

    


    @IBOutlet var localView:UIView!
    @IBOutlet var removeView:UIView!
    var rtcLocalView:RTCEAGLVideoView?
//    var rtcLocalView:RTCCameraPreviewView?
    var rtcRemoveView:RTCEAGLVideoView?
   var localVideoTrack:RTCVideoTrack?
   var removeVideoTrack:RTCVideoTrack?
    
    var rtcManager:RTCClient?
    var clientServer: RTCVideoServer?
    var rtcOperator: WebRTCOperator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        rtcLocalView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: localView.frame.width, height: localView.frame.height))
        rtcRemoveView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: removeView.frame.width, height: removeView.frame.height))
        
        localView.addSubview(rtcLocalView!)
        removeView.addSubview(rtcRemoveView!)
        
        
        let n = Int(arc4random_uniform(11142))
        let name = String(n)
        rtcManager = RTCClient(videoCall: true)
        clientServer = RTCVideoServer(url: "", client: rtcManager!)
        rtcOperator = WebRTCOperator(delegate: self,omgSocket: clientServer!)
        rtcManager?.delegate = rtcOperator
        clientServer?.registerMeetRoom("114", clientId: name)
        
        
        
//        _=setTimeout(delay: 15, block: switchCanera)
    }
    
    func switchCanera()
    {
        if(localVideoTrack != nil && (localVideoTrack!.source as? RTCAVFoundationVideoSource)?.canUseBackCamera == true){
            (localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera = !(localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera
        }
    }
    
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
//        rtcRemoveView?.renderFrame(RTCVideoFrame(buffer: <#T##RTCVideoFrameBuffer#>, rotation: <#T##RTCVideoRotation#>, timeStampNs: <#T##Int64#>))
        print("......videoView...\(videoView==rtcRemoveView)")
        rtcRemoveView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
    }
    
    
    func rtcClient(_ id: String, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
//        rtcLocalView?.captureSession=(localVideoTrack.source as! RTCAVFoundationVideoSource).captureSession
       self.localVideoTrack = localVideoTrack
        localVideoTrack.add(self.rtcLocalView!)
    }
    
    func rtcClient(_ id: String, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        print("[didReceive RemoteVideo Track..]")
        self.removeVideoTrack = remoteVideoTrack
        rtcRemoveView?.delegate = self
        remoteVideoTrack.add(self.rtcRemoveView!)
        //            remoteVideoTrack.isEnabled = true
        
        
    }
    
    func rtcClient(_ id: String, didReceiveError error: Error) {
        print("[Error]:\(error)")
    }
    
    func rtcClient(_ id: String, didChangeConnectionState connectionState: RTCIceConnectionState) {
        if(connectionState == .checking){
            print("[didChangeConnectionState]:checking)")
        }
        if(connectionState == .closed){
            print("[didChangeConnectionState]:closed)")
        }
        if(connectionState == .completed){
            print("[didChangeConnectionState]:completed)")
        }
        if(connectionState == .connected){
            print("[didChangeConnectionState]:connected)")
        }
        if(connectionState == .disconnected){
            print("[didChangeConnectionState]:disconnected)")
        }
        if(connectionState == .failed){
            print("[didChangeConnectionState]:failed)")
        }
    }
    


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


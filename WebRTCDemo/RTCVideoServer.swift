//
//  RTCVideoBase.swift
//  WebRTCDemo
//
//  Created by Hydeguo on 24/01/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import Starscream
import WebRTC


class RTCVideoServer: WebSocketDelegate ,OMGRTCServerDelegate{
    
    var client:RTCClient?
    private var socket:WebSocket?
    private var roomId:String = ""
    private var clientId:String = ""
    private var tempRemotSdp:String?
    
     var id:String = "main"
    /**
     url : handshake socket server url
     */
    init(url:String,client:RTCClient){
        socket = WebSocket(url: URL(string:url)!)
        socket?.delegate = self
        self.client = client
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        
        print("[websocket connected]")
        doRegister()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error {
            print("[websocket is disconnected: \(e.localizedDescription)]")
        } else {
            print("[websocket disconnected]")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
     
        onDataReceived(str: text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        print("Received data: \(data.count)")
        let dataString = String(data: data, encoding: .utf8)!
        onDataReceived(str: dataString)
        
    }
    
    func onDataReceived(str:String)
    {
        #if DEBUG
           print("[Received text]:\n___start___\n \(str)\n___end___")
        #endif
        let decoder = JSONDecoder()
        do {
            if(str.range(of: "\"type\":\"params\"") != nil){
                let param = try decoder.decode(Params.self, from: str.data(using: .utf8)!)
                var iceServers = [RTCIceServer]()
                for  iceServerdata in param.params.turn_server_override {
                    print("[ice server ]:\(iceServerdata.urls)")
                    iceServers.append(RTCIceServer(urlStrings: iceServerdata.urls, username: iceServerdata.username, credential: iceServerdata.credential))
                }
                client?.setIceServer(id, iceServers: iceServers)
                client?.startConnection(id)
                
                if(param.params.is_initiator == "true"){
                    self.client?.makeOffer(id)
                }
            }
            else if (str.range(of: "offer") != nil){
                let sdpSend:send = try decoder.decode(send.self, from: str.data(using: .utf8)!)
                
                let sdp:Sdp = try decoder.decode(Sdp.self, from: sdpSend.msg.data(using: .utf8)!)
                
                self.client?.createAnswerForOfferReceived(id, withRemoteSDP: sdp.sdp)
            }
            else if (str.range(of: "answer") != nil){
                let sdpSend:send = try decoder.decode(send.self, from: str.data(using: .utf8)!)
                let sdp:Sdp = try decoder.decode(Sdp.self, from: sdpSend.msg.data(using: .utf8)!)
                client?.handleAnswerReceived(id,withRemoteSDP: sdp.sdp)
            }
            else if (str.range(of: "candidate") != nil){
                let sdpSend:send = try decoder.decode(send.self, from: str.data(using: .utf8)!)
                let candidate:Candidate = try decoder.decode(Candidate.self, from: sdpSend.msg.data(using: .utf8)!)
                client?.addIceCandidate(id,iceCandidate: RTCIceCandidate(sdp: candidate.candidate, sdpMLineIndex: Int32(candidate.label), sdpMid: candidate.id))
            }
            else if (str.range(of: "bye") != nil){
                let sdpSend:send = try decoder.decode(send.self, from: str.data(using: .utf8)!)
                let _:Bye = try decoder.decode(Bye.self, from: sdpSend.msg.data(using: .utf8)!)
//                client?.disconnect()
            }
            
        } catch {
            print("[localStreamInited error]:\(error.localizedDescription)")
        }
        
    }
    
    
    func registerMeetRoom(_ roomId:String, clientId:String){
        
        self.roomId = roomId
        self.clientId = clientId
        socket?.connect()
        print("[registerMeetRoom]:\(roomId),clientId:\(clientId)")
        
    }
    
    func disconnectMeeting()
    {
        let props = ["cmd": "send", "msg":returnJsonStr(data: ["type":"bye"])] as [String : Any]
        socket?.write(string:returnJsonStr(data: props))
        socket?.disconnect()
        client?.disconnect(id)
    }
    
    deinit{
        socket?.disconnect()
        socket?.delegate = nil
        socket = nil
        client?.disconnect(id)
        client?.delegate = nil
        client = nil
    }
    
    private func doRegister()
    {
        let props = ["cmd": "register", "clientid":clientId,"roomid":roomId] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: props,
                                                      options: .prettyPrinted)
            socket?.write(string:String(data: jsonData, encoding: String.Encoding.utf8)!)
            print("[doRegister]:\(roomId),clientId:\(clientId)")
        } catch let error {
            print("error converting to json: \(error)")
        }
    }
    
    
    func sendMsg(string :String)
    {
        socket?.write(string: string)
    }
    
    
    private func returnJsonStr(data : [String : Any])->String
    {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data,
                                                      options: .prettyPrinted)
            return (String(data: jsonData, encoding: String.Encoding.utf8))!
        } catch let error {
            print("error converting to json: \(error)")
            return ""
        }
    }

}




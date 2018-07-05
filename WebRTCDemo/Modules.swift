//
//  Modules.swift
//  WebRTCDemo
//
//  Created by Hydeguo on 24/01/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


struct send : Codable {
    var cmd:String
    var msg:String
}

struct Params : Codable {
    var result:String
    var params:Params_detail
    var msg:[String:String]
}

//struct SendSdp : Codable {
//    var type:String
//    var sdp:Sdp
//}

struct Sdp : Codable {
    var type:String
    var sdp:String
}


struct Candidate : Codable {
    var type:String
    var id:String
    var label:Int
    var candidate:String
    
}

struct Bye : Codable {
    var type:String
}


struct Params_detail : Codable {
    var error_messages:[String]
    var messages:[String]
    var room_id:String
    var client_id:String
    var turn_server_override:[ice_server]
    var pc_config:String
    var is_initiator:String
    
}

struct ice_server : Codable {
    var urls:[String]
    var username:String?
    var credential:String?
}


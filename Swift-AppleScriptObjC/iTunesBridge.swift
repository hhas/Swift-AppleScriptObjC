//
//  Support.swift
//  Swift-AppleScriptObjC
//

import Cocoa



@objc(NSObject) protocol iTunesBridge {
    
    // Important: ASOC does not bridge C primitives, only Cocoa classes and objects,
    // so Swift Bool/Int/Double values MUST be explicitly boxed/unboxed as NSNumber
    // when passing to/from AppleScript.
    
    var isRunning: NSNumber { get } // Bool
    
    var playerState: NSNumber { get }
    
    var trackInfo: [NSString:AnyObject]? { get }
    var trackDuration: NSNumber { get }
    
    var soundVolume: NSNumber { get set }
    
    func playPause()
    func gotoPreviousTrack()
    func gotoNextTrack()
}


extension iTunesBridge { // native Swift versions of the above ASOC APIs
    
    var isRunning: Bool { return self.isRunning.boolValue }
    
    var playerState: PlayerState { return PlayerState(rawValue: self.playerState as! Int)! }
    
}


@objc enum PlayerState: Int { // iTunes' 'player state' property
    case unknown // extra case e.g. iTunes is not running
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}


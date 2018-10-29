//
//  AppDelegate.swift
//  Swift-AppleScriptObjC
//

import Cocoa
import AppleScriptObjC // ASOC adds its own 'load scripts' method to NSBundle


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    // Cocoa Bindings
    @objc dynamic var trackName: NSString!
    @objc dynamic var trackArtist: NSString!
    @objc dynamic var trackAlbum: NSString!
    
    @objc dynamic var trackDuration: NSNumber!
    
    @objc dynamic var soundVolume: NSNumber! {
        get { return self.iTunesBridge.isRunning ? self.iTunesBridge.soundVolume : 0 }
        set(value) { self.iTunesBridge.soundVolume = value }
    }
    
    @objc dynamic var playerState: PlayerState = .unknown
    
    // AppleScriptObjC object for communicating with iTunes
    var iTunesBridge: iTunesBridge
    
    override init() {
        // AppleScriptObjC setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        // create an instance of iTunesBridge script object for Swift code to use
        let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
        self.iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
        // general application setup
        ValueTransformer.setValueTransformer(PlayButtonNameTransformer(),
                                             forName: NSValueTransformerName(rawValue: "PlayButtonNameTransformer"))
        super.init()
    }

    //

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // iTunes emits track change notifications; very handy for UI refreshes
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector:#selector(AppDelegate.updateTrackInfo),
                         name:NSNotification.Name(rawValue:"com.apple.iTunes.playerInfo"), object:nil)
        // update UI only if iTunes is already running, otherwise wait until user performs an action
        if self.iTunesBridge.isRunning { self.updateTrackInfo() }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
//        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    //
    
    @objc func updateTrackInfo() {
        if let trackInfo = self.iTunesBridge.trackInfo { // nil indicates error, e.g. current track not available
            self.trackName = (trackInfo["trackName"] as! NSString)
            self.trackArtist = (trackInfo["trackArtist"] as! NSString)
            self.trackAlbum = (trackInfo["trackAlbum"] as! NSString)
            self.trackDuration = self.iTunesBridge.trackDuration
            self.playerState = self.iTunesBridge.playerState
        }
    }
    
    // buttons
    
    @IBAction func playPause(_ sender: Any) {
        self.iTunesBridge.playPause()
        self.updateTrackInfo()
    }
    
    @IBAction func gotoPreviousTrack(_ sender: Any) {
        self.iTunesBridge.gotoPreviousTrack()
        self.updateTrackInfo()
    }
    
    @IBAction func gotoNextTrack(_ sender: Any) {
        self.iTunesBridge.gotoNextTrack()
        self.updateTrackInfo()
    }
}



class PlayButtonNameTransformer: ValueTransformer {
    
    override static func transformedValueClass() -> Swift.AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let state = value else { return "Play" }
        return PlayerState(rawValue: state as! Int) == .playing ? "Pause" : "Play"
    }
}



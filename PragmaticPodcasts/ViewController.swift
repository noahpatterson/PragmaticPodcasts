//
//  ViewController.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/14/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player: AVPlayer?
    var playerPeriodicObserver: Any?
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet var trackTimeLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "http://traffic.libsyn.com/cocoaconf/marc.mp3") {
            setURL(url: url)
        } else {
            NSLog("error with url")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let player = object as? AVPlayer {
                playPauseButton.setTitle(player.rate == 0 ? "Play" : "Pause", for: .normal)
            }
        }
    }

    deinit {
        player?.removeObserver(self, forKeyPath: "rate")
        if let oldObserver = playerPeriodicObserver {
            player?.removeTimeObserver(oldObserver)
        }
    }
    

    @IBAction func handlePlayPausedTapped(_ sender: UIButton) {
        if let player = player {
            if player.rate == 0 {
                NSLog("play tapped")
                player.play()
                // best to not set here because the Audio may stop playing w/o hitting the button
//                playPauseButton.setTitle("Pause", for: .normal)
            } else {
                player.pause()
//                playPauseButton.setTitle("Play", for: .normal)
            }
        }
        
    }
    
    func updateTimeLabel(_ currentTime: CMTime) {
        let secondsInMinute: Double = 60.0
        let totalSeconds = currentTime.seconds
        let minutes      = Int(totalSeconds/secondsInMinute)
        let seconds      = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let secondsString = seconds >= 10 ? "\(seconds)" : "0\(seconds)"
        trackTimeLabel.text = "\(minutes):\(secondsString)"
    }
    
    func setURL(url: URL) {
        player = AVPlayer(url: url)
        trackLabel.text = url.lastPathComponent
        // kvo
        player?.addObserver(self,
                            forKeyPath: "rate",
                            options: [],
                            context: nil)
        
        //closure
        let timeInterval = CMTime(seconds: 0.25, preferredTimescale: 1000)
        // Reference Cycle
        //example of reference cycle. `player` has a reference to the closure but the closure has a reference to `self`.
        // “ViewController forces the player to remain in memory, and the closure we passed to the player keeps the ViewController in memory.”
        //playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: nil) {
        //                currentTime in self.updateTimeLabel(currentTime)
        //}
          playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: nil) {
                [weak self] currentTime in self?.updateTimeLabel(currentTime)
          }
            /* closure syntax
            { paramName1, paramName2, ... -> returnType ​in​ code... }
         
               weak reference closure syntax
            { [​weak​ capturedVar1, ...] paramName1, ... -> returnType ​in​ code... }
            */
    }
}


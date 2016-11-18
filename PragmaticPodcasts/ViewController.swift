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
        playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: timeInterval,
                                                                 queue: nil,
                                                                 using:
            { currentTime in NSLog("current time \(currentTime.seconds)") })
            
            /* closure syntax
            { paramName1, paramName2, ... -> returnType ​in​ code... }
            */
    }
}


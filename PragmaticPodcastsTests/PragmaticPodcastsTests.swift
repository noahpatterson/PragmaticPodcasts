//
//  PragmaticPodcastsTests.swift
//  PragmaticPodcastsTests
//
//  Created by Noah Patterson on 11/14/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import XCTest
import CoreMedia
@testable import PragmaticPodcasts

class PragmaticPodcastsTests: XCTestCase {
    
    var playerVC: ViewController?
    var startedPlayingExpectation: XCTestExpectation?
    var startedPlayingTimer: Timer?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //get the main storyboard
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        //get the PlayerViewController if we can
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? ViewController else { return }
        
        //load the views -- the "_" just assigns it to an empty variable
        let _ = playerVC.view
        
        //assign our scene to the local variable
        self.playerVC = playerVC
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayerTitleLabel_WhenURLIsSet_ShowsCorrectFilename() {
        // this guard makes sure that if the playerVC in setUp is nil then the test automatically fails
        guard let playerVC = playerVC else {
            XCTFail("Couldn't load player scene")
            return
        }
        XCTAssertEqual("marc.mp3", playerVC.trackLabel.text)
    }
    
    func testPlayerPlayPauseButton_WhenPressed_ShowsPause() {
        guard let playerVC = playerVC else {
            XCTFail("Couldn't load player scene")
            return
        }
        playerVC.handlePlayPausedTapped(playerVC.playPauseButton)
        XCTAssertEqual("Pause", playerVC.playPauseButton.currentTitle)
    }
    
    func timedPlaybackChecker(timer: Timer) {
        if let player = playerVC?.player, player.currentTime().seconds > 0 {
            startedPlayingExpectation?.fulfill()
            startedPlayingTimer?.invalidate()
        }
    }
    
    func testPlayerCurrentTime_WhenPlaying_IsNonZero() {
        guard let playerVC = playerVC else {
            XCTFail("Couldn't load player scene")
            return
        }
        
        startedPlayingExpectation = expectation(description: "player starts playing when tapped")
        startedPlayingTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                   target: self,
                                                   selector: #selector(timedPlaybackChecker),
                                                   userInfo: nil,
                                                   repeats: true)
        
        playerVC.handlePlayPausedTapped(playerVC.playPauseButton)
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    
    
}

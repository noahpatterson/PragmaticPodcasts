//
//  AppDelegate.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/14/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        if let url = URL(string: "http://cocoaconf.libsyn.com/rss") {
//            let parser = PodcastFeedParser.init(contentsOf: url)
//        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //refresh podcast list when app fully launches and ui is present or and restore from background
//        if let url = URL(string: "http://cocoaconf.libsyn.com/rss"), let episodeListVC = application.keyWindow?.rootViewController as? EpisodeListViewController {
        if let url = URL(string: "http://cocoaconf.libsyn.com/rss"), let topNav = application.keyWindow?.rootViewController as? UINavigationController, let episodeListVC = topNav.viewControllers.first as? EpisodeListViewController {
            let objectContext = coreDataStack.persistentContainer.viewContext
            let parser = PodcastFeedParser(contentsOf: url, sharedObjectContext: objectContext)
            parser.onParserFinished = {
                [weak episodeListVC, weak self] in
                if let feed = parser.currentFeed {
                    episodeListVC?.feeds = [feed]
                    
                    
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        coreDataStack.saveContext()
    }

}


//
//  EpisodeListViewController.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/26/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit
import CoreData

class EpisodeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    
    var feeds: [Feed] = [] {
        didSet {
            //use main queue because it touches the UI by reloading feeds. We cannot gaurntee that the thing setting 'feeds' is doing so on the main queue.
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
    }
    
    
    @IBAction func unWindToEpisodeList(_ segue: UIStoryboardSegue) {
        if let addPodcastVC = segue.source as? AddPodcastViewController, let urlText = addPodcastVC.urlField.text, let url = URL(string: urlText) {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context     = appDelegate?.coreDataStack.persistentContainer.viewContext
            let parser = PodcastFeedParser(contentsOf: url, sharedObjectContext: context!)
            parser.onParserFinished = {
                [weak self] in
//                if let feed = parser.currentFeed {
//                    self?.feeds.append(feed)
//                }
                let request = NSFetchRequest<Feed>(entityName: "Feed")
                do {
                    if let fetched = try context?.fetch(request) {
                        self?.feeds = fetched
                    }
                    print("Got \(self?.feeds.count) feeds")
                } catch {
                    print("Fetch failed")
                }
            }
        }
    }
    
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    //number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return feeds[section].episodes.count
        var count = 0
        if let episodes = feeds[section].episodes {
            count = episodes.count
        }
        return count
    }
  
    //populate the episode cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let episode = feeds[indexPath.section].episodes[indexPath.row]
        let episode = feeds[indexPath.section].episodes?.allObjects[indexPath.row] as? Episode
        let cell    = table.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        cell.titleLabel.text    = episode?.title
        cell.durationLabel.text = episode?.itunesDuration
        
        //image
        cell.artworkImageView.image = nil
        if let url = episode?.itunesImageUrl, let urlObject = URL(string: url) {
            cell.loadingImageUrl = urlObject
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: urlObject) {
                dataMb, responseMb, errorMb in
                if let data = dataMb, urlObject == cell.loadingImageUrl {
                    DispatchQueue.main.async {
                        cell.artworkImageView.image = UIImage(data: data)
                    }
                }
            }
            dataTask.resume()
        }
        return cell   
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return feeds[section].title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayer", let playerVC = segue.destination as? PlayerViewController, let indexPath = table.indexPathForSelectedRow {
            if let episode = feeds[indexPath.section].episodes?.allObjects[indexPath.row] as? Episode {
                
//                let podcastEpisode = PodcastEpisode(title: episode.title!, episodeUrl: URL(string: episode.episodeUrl!), itunesDuration: episode.itunesDuration!, itunesImageURL: URL(string: episode.itunesImageUrl!))
                playerVC.episode = episode
            }
        }
    }
}

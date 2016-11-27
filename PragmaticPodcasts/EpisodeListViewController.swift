//
//  EpisodeListViewController.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/26/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit

class EpisodeListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var table: UITableView!
    
    var feeds: [PodcastFeed] = [] {
        didSet {
            //use main queue because it touches the UI by reloading feeds. We cannot gaurntee that the thing setting 'feeds' is doing so on the main queue.
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
    }
    
    //number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    //number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds[section].episodes.count
    }
  
    //populate the episode cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let episode = feeds[indexPath.section].episodes[indexPath.row]
        let cell    = table.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        
        cell.titleLabel.text    = episode.title
        cell.durationLabel.text = episode.itunesDuration
        
        //image
        cell.artworkImageView.image = nil
        if let url = episode.itunesImageURL {
            cell.loadingImageUrl = url
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: url) {
                dataMb, responseMb, errorMb in
                if let data = dataMb, url == cell.loadingImageUrl {
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
}

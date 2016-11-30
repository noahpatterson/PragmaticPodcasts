//
//  PodcastEpisodeParser.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/25/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import Foundation
import CoreData

class PodcastEpisodeParser: NSObject, XMLParserDelegate {
    let feedParser: PodcastFeedParser
    var currentEpisode: PodcastEpisode
    var currentElementText: String?
    
    //core data
    var context: NSManagedObjectContext
    var episode: Episode
    
    init(feedParser: PodcastFeedParser, xmlParser: XMLParser, sharedObject: NSManagedObjectContext) {
        self.feedParser = feedParser
        self.currentEpisode = PodcastEpisode()
        self.context = sharedObject
        self.episode = Episode(context: context)
        super.init()
        xmlParser.delegate = self
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "title", "itunes:duration":
            currentElementText = ""
        case "enclosure":
            if let href = attributeDict["url"], let url = URL(string: href) {
                currentEpisode.episodeUrl = url
                episode.episodeUrl = href
            }
            fallthrough
        case "itunes:image":
            if let href = attributeDict["href"], let url = URL(string: href) {
                currentEpisode.itunesImageURL = url
                episode.itunesImageUrl = href
            }
            fallthrough
        default:
            currentElementText = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementText?.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            currentEpisode.title = currentElementText
            episode.title        = currentElementText
        case "itunes:duration":
            currentEpisode.itunesDuration = currentElementText
            episode.itunesDuration        = currentElementText
        case "item":
            parser.delegate = feedParser
            feedParser.parser(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
        default:
            break
        }
    }
}

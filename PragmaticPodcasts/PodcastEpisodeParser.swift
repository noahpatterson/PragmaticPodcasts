//
//  PodcastEpisodeParser.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/25/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import Foundation

class PodcastEpisodeParser: NSObject, XMLParserDelegate {
    let feedParser: PodcastFeedParser
    var currentEpisode: PodcastEpisode
    var currentElementText: String?
    
    init(feedParser: PodcastFeedParser, xmlParser: XMLParser) {
        self.feedParser = feedParser
        self.currentEpisode = PodcastEpisode()
        super.init()
        xmlParser.delegate = self
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "title", "itunes:duration", "itunes:image":
            currentElementText = ""
        case "enclosure":
            if let href = attributeDict["url"], let url = URL(string: href) {
                currentEpisode.episodeUrl = url
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
        case "itunes:duration":
            currentEpisode.itunesDuration = currentElementText
        case "itunes:image":
            if let urlText = currentElementText {
                currentEpisode.itunesImageURL = URL(string: urlText)
            }
        case "item":
            parser.delegate = feedParser
            feedParser.parser(parser, didEndElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName)
        default:
            break
        }
    }
}

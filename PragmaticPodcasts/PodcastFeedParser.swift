//
//  PodcastFeedParser.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/19/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import Foundation
import CoreData

class PodcastFeedParser: NSObject, XMLParserDelegate {
    var currentFeed: PodcastFeed?
    var currentElementText: String?
    var episodeParser: PodcastEpisodeParser?
    var context: NSManagedObjectContext
    var feed: Feed
    
    // a closure that has no arguments and returns no value. Optional.
    var onParserFinished: (() -> Void)?
    
    init(contentsOf url: URL, sharedObjectContext: NSManagedObjectContext) {
        
        context = sharedObjectContext
        feed    = Feed(context: context)
        super.init()
    
        let urlSession = URLSession(configuration: .default)
        let dataTask   = urlSession.dataTask(with: url) {
            dataMb, responseMb, errorMb in
            if let data = dataMb {
//                if let dataString = String(data: data, encoding: .utf8) {
//                    NSLog("url dataString: \(dataString)")
//                }
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }
        dataTask.resume()
    }
    
    // MARK: - XMLParserDelegate implementation​ - 
    //XMLParserDelegate is tedious but it “saves the memory hit of creating an entire DOM that we might only want a tiny fraction of”
    func parserDidStartDocument(_ parser: XMLParser) {
        NSLog("parserDidStartDocument, currently on line: \(parser.lineNumber)")
        currentFeed = PodcastFeed()
    }
    
    //callback that knows when we find a element we are looking for
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
            case "title", "link", "description", "itunes:author":
                currentElementText = ""
            case "itunes:image":
                if let href = attributeDict["href"], let url = URL(string: href) {
                    currentFeed?.itunesImageUrl = url
                    feed.itunesImageUrl = href
                }
                fallthrough
            case "item":
                episodeParser = PodcastEpisodeParser(feedParser: self, xmlParser: parser, sharedObject: context)
                parser.delegate = episodeParser
            default:
                currentElementText = nil
            }
    }
    
    //when the parser finds characters in the element. Is called multiple times so it's best to build the string.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementText?.append(string)
    }
    
    //when the parser reaches the end of an element, write the string to the model.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            currentFeed?.title = currentElementText
            feed.title = currentElementText
        case "link":
            if let linkText = currentElementText {
                currentFeed?.link = URL(string: linkText)
                feed.link = linkText
            }
        case "description":
                currentFeed?.description = currentElementText
                feed.feedDescription = currentElementText
        case "itunes:author":
            currentFeed?.itunesAuthor = currentElementText
            feed.itunesAuthor = currentElementText
        case "item":
            if let episode = episodeParser?.currentEpisode, let episodeData = episodeParser?.episode {
                currentFeed?.episodes.append(episode)
                feed.addToEpisodes(episodeData)
            }
            episodeParser = nil
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
//        NSLog("parsing done, feed is \(currentFeed)")
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        onParserFinished?()
    }
}

//
//  PodcastFeedParser.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/19/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import Foundation

class PodcastFeedParser: NSObject, XMLParserDelegate {
    var currentFeed: PodcastFeed?
    var currentElementText: String?
    
    init(contentsOf url: URL) {
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
    
    // MARK: - XMLParserDelegate implementation​
    func parserDidStartDocument(_ parser: XMLParser) {
        NSLog("parserDidStartDocument, currently on line: \(parser.lineNumber)")
        currentFeed = PodcastFeed()
    }
    
    //callback that knows when we find a element we are looking for
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
            case "title", "link", "description", "itunes:image", "itunes:author":
                currentElementText = ""
            case "item":
                parser.abortParsing()
                NSLog("aborted parsing. podcastFeed = \(currentFeed)")
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
        case "link":
            if let linkText = currentElementText {
                currentFeed?.link = URL(string: linkText)
            }
        case "descrtiption":
                currentFeed?.description = currentElementText
        case "itunes:author":
            currentFeed?.itunesAuthor = currentElementText
        case "itunes:image":
            if let urlText = currentElementText {
                currentFeed?.itunesImageUrl = URL(string: urlText)
            }
        default:
            break
        }
    }
}

//
//  PodcastFeedParser.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/19/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import Foundation

class PodcastFeedParser: NSObject, XMLParserDelegate {
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
    
    func parserDidStartDocument(_ parser: XMLParser) {
        NSLog("parserDidStartDocument, currently on line: \(parser.lineNumber)")
    }
    
}

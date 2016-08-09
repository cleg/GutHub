//
//  FavouritesItem.swift
//  GutHub
//
//  Created by Paul Dmitryev on 08.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation

class GitHubFavourite: NSObject, NSCoding {
    let name: String
    let slugUrl: NSURL
    
    init(_ name: String, slugUrl: NSURL) {
        self.name = name
        self.slugUrl = slugUrl
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.slugUrl = NSURL(string: aDecoder.decodeObjectForKey("url") as! String)!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(slugUrl.absoluteString, forKey: "url")
    }
}

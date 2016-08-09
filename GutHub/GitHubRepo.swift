//
//  GitHubRepo.swift
//  GutHub
//
//  Created by Paul Dmitryev on 04.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation

struct GitHubRepo {
    var name: String
    var attributedName: NSMutableAttributedString?
    var description: String
    var attributedDescription: NSMutableAttributedString?
    var updated: String
    var lang: String
    var stars: Int
    var forks: Int
    var watching: Int
    var webUrl: NSURL
    var slugUrl: NSURL
    var avatarUrl: NSURL
    
    func favItem() -> GitHubFavourite {
        return GitHubFavourite(name, slugUrl: slugUrl)
    }
}

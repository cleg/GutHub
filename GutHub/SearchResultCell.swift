//
//  SearchResultCell.swift
//  GutHub
//
//  Created by Paul Dmitryev on 04.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import UIKit


class SearchResultCell: UITableViewCell {
    static let identifier = "SearchResultCell"
    
    var repos: GitHubRepo? {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var favIndicatoLabel: UILabel!
    
    
    func updateCell() {
        guard let repos = repos else {
            return
        }
        
        avatarImage.image = nil

        if let attName = repos.attributedName {
            nameLabel.attributedText = attName
        } else {
            nameLabel.text = repos.name
        }
        if let attDescr = repos.attributedDescription {
            descriptionLabel.attributedText = attDescr
        } else {
            descriptionLabel.text = repos.description
        }
        
        forksLabel.text = "\(repos.forks)"
        starsLabel.text = "\(repos.stars)"
        watchLabel.text = "\(repos.watching)"
        langLabel.text = repos.lang
        favIndicatoLabel.text = FavoritesList.sharedFavoritesList.containsRepos(repos.slugUrl) ? "⭐️": ""
        
        avatarImage.downloadedFrom(repos.avatarUrl)
    }
}

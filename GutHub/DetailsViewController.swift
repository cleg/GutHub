//
//  DetailsViewController.swift
//  GutHub
//
//  Created by Paul Dmitryev on 05.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var readMeText: UITextView!
    @IBOutlet weak var favouritesSwitch: UISwitch!
    @IBOutlet weak var openInBrowserBarItem: UIBarButtonItem!
    
    var favItem: GitHubFavourite?
    var repoData: GitHubRepo?
    var ghApi = GitHubAPI()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        openInBrowserBarItem.enabled = false
        updateView()
    }
    
    func setReposData(repos: GitHubRepo) {
        repoData = repos
        nameLabel?.text = repos.name
        avatarImage?.downloadedFrom(repos.avatarUrl)
        openInBrowserBarItem.enabled = true
    }
    
    func setReadme(str: NSAttributedString) {
        readMeText?.attributedText = str
    }
    
    func updateView() {
        guard let item = favItem else {
            return
        }
        nameLabel?.text = item.name
        ghApi.getDetails(item.slugUrl, onSuccess: setReposData)
        ghApi.getReadme(item.slugUrl, onSuccess: setReadme)
        favouritesSwitch?.on = FavoritesList.sharedFavoritesList.containsRepos(item.slugUrl)
    }

    @IBAction func favouritesSwitchFlip(sender: UISwitch) {
        guard let favItem = favItem else {
            return
        }
        
        if sender.on {
            FavoritesList.sharedFavoritesList.addFavorite(favItem)
        } else {
            FavoritesList.sharedFavoritesList.removeFavorite(favItem)
        }
    }
    
    @IBAction func openInBrowserButtonTap(sender: UIBarButtonItem) {
        guard let repoData = repoData else {
            return
        }
        UIApplication.sharedApplication().openURL(repoData.webUrl)
    }
}

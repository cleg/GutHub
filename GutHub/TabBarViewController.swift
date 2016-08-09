//
//  TabBarViewController.swift
//  GutHub
//
//  Created by Paul Dmitryev on 08.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarViewController.favouritesChangedNotification(_:)), name: FavouritesItemChanged, object: nil)
        updateBadge()
    }

    func favouritesChangedNotification(notification: NSNotification){
        updateBadge()
    }
    
    func updateBadge() {
        tabBar.items![1].badgeValue = FavoritesList.sharedFavoritesList.favorites.count>0 ? "\(FavoritesList.sharedFavoritesList.favorites.count)" : nil
    }
}

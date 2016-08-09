//
//  FavouritesList.swift
//  GutHub
//
//  Created by Paul Dmitryev on 08.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation
import UIKit

class FavoritesList {
    static let sharedFavoritesList = FavoritesList()
    private(set) var favorites:[GitHubFavourite]
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let storedFavorites = defaults.objectForKey("favorites") as? [GitHubFavourite]
        favorites = storedFavorites != nil ? storedFavorites! : []
    }
    
    func addFavorite(item: GitHubFavourite) {
        if !favorites.contains({$0.slugUrl == item.slugUrl}) {
            favorites.append(item)
            NSNotificationCenter.defaultCenter().postNotificationName(FavouritesItemChanged, object: nil)
            saveFavorites()
        }
    }
    
    func removeFavorite(item: GitHubFavourite) {
        if let index = favorites.indexOf({$0.slugUrl == item.slugUrl}) {
            favorites.removeAtIndex(index)
            NSNotificationCenter.defaultCenter().postNotificationName(FavouritesItemChanged, object: nil)
            saveFavorites()
        }
    }
    
    func removeFavourite(atIndex index: Int) {
        favorites.removeAtIndex(index)
        NSNotificationCenter.defaultCenter().postNotificationName(FavouritesItemChanged, object: nil)
        saveFavorites()
    }
    
    func containsRepos(slugUrl: NSURL) -> Bool {
        return favorites.contains({$0.slugUrl == slugUrl})
    }
    
    func moveItem(fromIndex from: Int, toIndex to: Int) {
        let item = favorites[from]
        favorites.removeAtIndex(from)
        favorites.insert(item, atIndex: to)
        NSNotificationCenter.defaultCenter().postNotificationName(FavouritesItemChanged, object: nil)
        saveFavorites()
    }
    
    private func dataFileURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(
            .DocumentDirectory, inDomains: .UserDomainMask)
        return urls.first!.URLByAppendingPathComponent("favs.plist")
    }
    
    private func getPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.AllDomainsMask, true)
        let path: AnyObject = paths[0]
        return path.stringByAppendingString("/favs.plist")
    }
    
    private func saveFavorites() {
        let arrPath = getPath()
        NSKeyedArchiver.archiveRootObject(favorites, toFile: arrPath)
    }
    
    func loadFavourites() {
        let arrPath = getPath()
        if let tempArr: [GitHubFavourite] = NSKeyedUnarchiver.unarchiveObjectWithFile(arrPath) as? [GitHubFavourite] {
            favorites = tempArr
        }
    }
}

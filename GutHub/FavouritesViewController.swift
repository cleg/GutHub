//
//  FavouritesViewController.swift
//  GutHub
//
//  Created by Paul Dmitryev on 08.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import UIKit

class FavouritesViewController: UITableViewController {
    static let cellIdentifier = "FavouritesCell"
    var ourTableEditing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavouritesViewController.favouritesChangedNotification(_:)), name: FavouritesItemChanged, object: nil)

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func favouritesChangedNotification(notification: NSNotification){
        // if we got notification during table editing, then we don't need to reload data
        if !ourTableEditing {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FavoritesList.sharedFavoritesList.favorites.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FavouritesViewController.cellIdentifier, forIndexPath: indexPath)

        cell.textLabel?.text = FavoritesList.sharedFavoritesList.favorites[indexPath.row].name

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        ourTableEditing = true
        if editingStyle == .Delete {
            FavoritesList.sharedFavoritesList.removeFavourite(atIndex: indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        ourTableEditing = false
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        FavoritesList.sharedFavoritesList.moveItem(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FavouritesDetailSeague" {
            guard let detailsVC = segue.destinationViewController as? DetailsViewController else {
                return
            }
            guard let row = tableView.indexPathForSelectedRow?.row else {
                return
            }
            detailsVC.favItem = FavoritesList.sharedFavoritesList.favorites[row]
        }
    }
}

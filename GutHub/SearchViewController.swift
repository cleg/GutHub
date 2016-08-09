//
//  ViewController.swift
//  GutHub
//
//  Created by Paul Dmitryev on 03.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import UIKit
import SVProgressHUD

class SearchViewController: UITableViewController, UISearchBarDelegate {
    var data: [GitHubRepo] = []
    var page: Int = 1
    var haveMore = true
    let ghAPI = GitHubAPI()
    let sorts = [0: "", 1: "stars", 2: "forks", 3: "updated"]
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        if let searchText = NSUserDefaults.standardUserDefaults().stringForKey("search") {
            searchBar.text = searchText
        }
        
        searchBar.selectedScopeButtonIndex = NSUserDefaults.standardUserDefaults().integerForKey("sort")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavouritesViewController.favouritesChangedNotification(_:)), name: FavouritesItemChanged, object: nil)
        
        SVProgressHUD.setDefaultStyle(.Dark)
        
        searchBar.delegate = self
        doSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImagesCahche.purgeCache()
    }

    // MARK: API call delegate
    func doGetResults(data: [GitHubRepo]) {
        if data.count < 100 {
            // if we have less then 100 results, than github is out of data
            haveMore = false
        }
        self.data.appendContentsOf(data)
        tableView.reloadData()
    }

    // MARK: Table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchResultCell.identifier) as! SearchResultCell
        cell.repos = data[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastElement = data.count - 1
        if indexPath.row == lastElement && haveMore {
            page += 1
            doSearch()
        }
    }

    func favouritesChangedNotification(notification: NSNotification){
        tableView.reloadData()
    }
    
    // MARK: Search
    
    func startNewSearch() {
        data = []
        page = 1
        haveMore = true
        // we need to clear table
        tableView.reloadData()
    }
    
    func doSearch() {
        let buttonIndex = searchBar.selectedScopeButtonIndex
        if let query = searchBar.text {
            NSUserDefaults.standardUserDefaults().setObject(query, forKey: "search")
            NSUserDefaults.standardUserDefaults().setInteger(buttonIndex, forKey: "sort")
            ghAPI.search(query, page: page, sort: sorts[buttonIndex]!, onSuccess: doGetResults)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        startNewSearch()
        doSearch()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        startNewSearch()
        doSearch()
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetailsFromSearch" {
            guard let detailsVC = segue.destinationViewController as? DetailsViewController else {
                return
            }
            guard let row = tableView.indexPathForSelectedRow?.row else {
                return
            }
            detailsVC.favItem = data[row].favItem()
        }
    }
}


//
//  GitHubAPI.swift
//  GutHub
//
//  Created by Paul Dmitryev on 04.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation
import SwiftyMarkdown
import SVProgressHUD

// TODO: highlight strings

class GitHubAPI {
    private var searchTask: NSURLSessionDataTask?
    
    // get matches records from github
    private func getTextMatches(matchList: [[String: AnyObject]], matchFor: String) -> [NSRange] {
        var results: [NSRange] = []
        for matchItem in matchList {
            if matchItem["property"] as! String == matchFor {
                if let matches = matchItem["matches"] as? [[String: AnyObject]] {
                    for match in matches {
                        if let indexes = match["indices"] as? [Int] {
                            let range = NSMakeRange(indexes[0], indexes[1] - indexes[0])
                            results.append(range)
                        }
                    }
                }
            }
        }
        return results
    }
    
    private func highlightString(source: String, matches: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(string: source)
        for range in matches {
            result.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: range)
        }
        return result
    }
    
    private func parseGitHubResonse(item: [String: AnyObject]) -> GitHubRepo {
        let name = item["name"] as! String
        var descr = ""
        if let desc = item["description"] as? String {
            descr = desc
        }
        let updated = item["updated_at"] as! String
        var lang = "?"
        if let language = item["language"] as? String {
            lang = language
        }
        let stars = item["stargazers_count"] as! Int
        let forks = item["forks"] as! Int
        let watching = item["watchers"] as! Int
        let webUrl = NSURL(string: item["html_url"] as! String)!
        let slugUrl = NSURL(string: item["url"] as! String)!
        let avatarUrl = NSURL(string: (item["owner"] as! [String : AnyObject])["avatar_url"] as! String)!
        
        var attName: NSMutableAttributedString? = nil
        var attDescr: NSMutableAttributedString? = nil
        if let textMatches = item["text_matches"] as? [[String:AnyObject]] {
            let nameMatches = getTextMatches(textMatches, matchFor: "name")
            attName = highlightString(name, matches: nameMatches)

            let descrMatches = getTextMatches(textMatches, matchFor: "description")
            attDescr = highlightString(descr, matches: descrMatches)
        }
        
        return GitHubRepo(name: name, attributedName: attName, description: descr, attributedDescription: attDescr, updated: updated, lang: lang, stars: stars, forks: forks, watching: watching, webUrl: webUrl, slugUrl: slugUrl, avatarUrl: avatarUrl)
    }
    
    // Perform repository search
    func search(query: String, page: Int=1, sort: String="", onSuccess: ([GitHubRepo])->Void) {
        var collectedData: [GitHubRepo] = []
        searchTask?.cancel()
        let urlStr = "https://api.github.com/search/repositories?q=\(query)&page=\(page)&per_page=100&sort=\(sort)"
        guard let reqUrl = NSURL(string: urlStr) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: reqUrl)
        // set header to get matches records from GH
        request.addValue("application/vnd.github.v3.text-match+json", forHTTPHeaderField: "Accept")
        
        searchTask = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    SVProgressHUD.popActivity()
                }
            }
            if let data = data {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
                    guard let jsonArray = jsonData["items"] as? [[String:AnyObject]] else {
                        NSLog("Error getting search array")
                        return
                    }
                    
                    for repos in jsonArray {
                        collectedData.append(self.parseGitHubResonse(repos))
                    }                    
                } catch let jsonError as NSError {
                    NSLog("JSON error in search \(jsonError)")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    onSuccess(collectedData)
                }
            } else {
                if let error = error {
                    NSLog("Error getting search data \(error.localizedDescription)")
                }
            }
        }
        SVProgressHUD.show()
        searchTask?.resume()
    }
    
    // Get details about repos
    func getDetails(slugUrl: NSURL, onSuccess: (GitHubRepo) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(slugUrl) {
            (data, response, error) in
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    SVProgressHUD.popActivity()
                }
            }
            if let data = data {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
                    guard let jsonDict = jsonData as? [String:AnyObject] else {
                        NSLog("Error getting details array")
                        return
                    }
                    let repos = self.parseGitHubResonse(jsonDict)
                    dispatch_async(dispatch_get_main_queue()) {
                        onSuccess(repos)
                    }
                } catch let jsonError as NSError {
                    NSLog("JSON error in details \(jsonError)")
                }
            } else {
                if let error = error {
                    NSLog("Error getting details data \(error.localizedDescription)")
                }
            }
        }
        SVProgressHUD.show()
        task.resume()
    }
    
    // Fetch readme file for repos
    func getReadme(slugUrl: NSURL, onSuccess: (NSAttributedString) -> Void) {
        let readmeUrl = NSURL(string: "\(slugUrl.absoluteString)/readme")!
        let task = NSURLSession.sharedSession().dataTaskWithURL(readmeUrl) {
            (data, response, error) in
            defer {
                dispatch_async(dispatch_get_main_queue()) {
                    SVProgressHUD.popActivity()
                }
            }
            if let data = data {
                do {
                    var atts = NSAttributedString()
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
                    let jsonDict = jsonData as! [String: AnyObject]
                    if let readMeAddr = jsonDict["download_url"], let readmeUrl = NSURL(string: readMeAddr as! String) {
                        if let md = SwiftyMarkdown(url: readmeUrl) {
                            atts = md.attributedString()
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        onSuccess(atts)
                    }
                } catch let error as NSError {
                    NSLog("Error getting readme data \(error.localizedDescription)")
                }
            }
        }
        SVProgressHUD.show()
        task.resume()
    }
}

//
//  ImageUtils.swift
//  GutHub
//
//  Created by Paul Dmitryev on 05.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation
import UIKit

private var urlsList: [UIImageView: NSURL] = [:]
private var tasksList: [UIImageView: NSURLSessionDataTask] = [:]

extension UIImageView {
    func downloadedFrom(url: NSURL, contentMode mode: UIViewContentMode = UIViewContentMode.ScaleAspectFit) {
        if let runningTask = tasksList[self] {
            runningTask.cancel()
        }

        contentMode = mode

        let imgData = ImagesCahche.sharedCache.objectForKey(url)
        if let data = imgData as? NSData {
            self.image = UIImage(data: data)
        } else {
            let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url) {
                (data, response, error) in
                if let data = data {
                    ImagesCahche.sharedCache.setObject(data, forKey: url, cost: data.length)
                    // another cell here, we don't need this data anymore
                    if url != urlsList[self] {
                            return
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.image = UIImage(data: data)
                    }
                } else {
                    if error!.localizedDescription != "cancelled" {
                        NSLog(error!.localizedDescription)
                    }
                }
            }
            urlsList[self] = url
            tasksList[self] = downloadTask
            downloadTask.resume()
        }
    }
}
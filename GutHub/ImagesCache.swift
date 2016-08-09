//
//  ImagesCache.swift
//  GutHub
//
//  Created by Paul Dmitryev on 08.08.16.
//  Copyright © 2016 Taburetka. All rights reserved.
//

import Foundation

class ImagesCahche {
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 32
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()
    
    static func purgeCache() {
        ImagesCahche.sharedCache.removeAllObjects()
    }
}
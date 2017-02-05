//
//  MovieModel.swift
//  Flicks
//
//  Created by Jake Vo on 2/4/17.
//  Copyright © 2017 Jake Vo. All rights reserved.
//

import Foundation

import UIKit

class MovieModel: NSObject {
    var imageURL:URL = URL(string: "www.google.com")!
    var title:String = ""
    var overview:String = ""
    init(title:String,overview:String,imageURL:URL) {
        self.imageURL = imageURL
        self.title = title
        self.overview = overview
    }
}

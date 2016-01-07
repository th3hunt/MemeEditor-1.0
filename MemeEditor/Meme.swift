//
//  Meme.swift
//  MemeEditor
//
//
//
//  Created by Stratos Pavlakis on 07/01/16.
//  Copyright © 2016 Stratos Pavlakis. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    let topText: String
    let bottomText: String
    let image: UIImage
    let originalImage: UIImage
    
    init(_ image: UIImage, topText: String, bottomText: String, originalImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.originalImage = originalImage
    }
    
}
//
//  imageProperties.swift
//  Networking_Get_Post
//
//  Created by Antbook on 05.08.2021.
//

import Foundation
import UIKit


struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else {return nil} //.pngData конвертирует из UIImage png в Data
        self.data = data
    }
    
}



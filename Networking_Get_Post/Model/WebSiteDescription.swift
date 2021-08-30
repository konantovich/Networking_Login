//
//  WebSiteDescription.swift
//  Networking_Get_Post
//
//  Created by Antbook on 02.08.2021.
//

import Foundation

struct WebSiteDescription: Decodable {
    let websiteDescription : String
    let websiteName : String?
    let courses: [ApiStruct]
}

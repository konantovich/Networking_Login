//
//  UserProfile.swift
//  Networking_Get_Post
//
//  Created by Antbook on 25.08.2021.
//

import Foundation



struct UserProfile {
    let id : Int?
    let name : String?
    let email: String?
    
    init(data: [String : Any]) {
        let id = data["id"] as? Int
        let name = data["name"] as? String
        let email = data["email"] as? String
        
        self.id = id
        self.name = name
        self.email = email
        
    }
    
    
}

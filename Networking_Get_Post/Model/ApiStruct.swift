//
//  ApiStruct.swift
//  Networking_Get_Post
//
//  Created by Antbook on 02.08.2021.
//

// https://swiftbook.ru/wp-content/uploads/api/api_course
import Foundation
import UIKit

//эта модель и для URLSession и для Alamofire
struct ApiStruct : Decodable {
    let id : Int
    let name : String
    let link: String
    let imageUrl: String
    let numberOfLessons: Int?
    let numberOfTests: Int?
}


//модель для Alamofire (оптимизируем)
struct ApiStructAlamofire : Decodable {
    let id : Int
    let name : String
    let link: String
    let imageUrl: String
    let numberOfLessons: String?
    let numberOfTests: String?
    
    init?(json: [String: Any]) {
        let id = json["id"] as? Int ?? 0
        let name = json["name"] as? String ?? ""
        let link = json["link"] as? String ?? ""
        let imageUrl = json["imageUrl"] as? String ?? ""
        let numberOfLessons = json["numberOfLessons"] as? String
        let numberOfTests = json["numberOfTests"] as? String
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    static func getArray(from jsonArray: Any) -> [ApiStructAlamofire]? {
        guard let jsonArray = jsonArray as? Array<[String:Any]> else {return nil}
        
        var courses: [ApiStructAlamofire] = []
        
        
        for field in jsonArray {
            guard let course = ApiStructAlamofire(json: field) else {return nil}
            courses.append(course)
        }
        return courses
        
        //все выше в методе getArray(кроме 1й строчки, можно поместить в одну строчку ниже
       return jsonArray.compactMap{ApiStructAlamofire(json: $0)}
        
    }
    
}



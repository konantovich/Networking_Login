//
//  NetworkManager.swift
//  Networking_Get_Post
//
//  Created by Antbook on 04.08.2021.
//

import Foundation
import UIKit

class NetworkManager  {
    
    func getRequest(url: String) {
        guard let url = URL(string: url) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in //response позволяет обработать ответ сервера
            guard let response = response, let data = data else { return }
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func postRequest (url: String) {
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course" : "Networking", "Lesson" : "Get and POST Requests"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //добавить заменить или удалить
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else {return} //кодируем в json
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //получаем то что добавили на сервер
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let response = response, let data = data else {return}
           // print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func downloadImage (url: String, completion: @escaping (_ image: UIImage)->())  {
       
            
            guard let url = URL(string: url) else { return }
            
            let urlSession = URLSession.shared //для работы с сетевыми запросами
            
            urlSession.dataTask(with: url) { data, respose, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                       completion(image)
                    }
                }
            }.resume()
        
    }
    
    
    func fetchData(jsonUrlString: String, completion:  @escaping (_ apiStruct: [ApiStructAlamofire]) -> () )  {
        // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_course"
         let jsonUrlString = jsonUrlString//"https://swiftbook.ru/wp-content/uploads/api/api_courses"
        // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_website_description"
        // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_missing_or_wrong_fields"
        
        guard let url = URL(string: jsonUrlString) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {return}
           
            do {
                let decoder = JSONDecoder()
                
               // decoder.keyDecodingStrategy = .convertFromSnakeCase //позволяет в первую API структуру сразу писать в кемелКейс стиле
                
                let courses = try decoder.decode([ApiStructAlamofire].self, from: data)
                
               completion(courses)
                
            } catch let error {
                print("json serialization error: ", error)
            }
            
            
        }.resume()
        
    }
    
    
    
    func uploadImage (url: String) {
        let image = UIImage(named: "Imagetest")!
        let httpHeaders = ["Authorization" : "Client-ID f9529bd757695b7"]
        guard let imageProperties = ImageProperties(withImage: image, forKey: "image") else {return}
        
        guard let url = URL(string: url) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //метод
        request.allHTTPHeaderFields = httpHeaders //параметры авторизации
        request.httpBody = imageProperties.data //изображение
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let jsone = try JSONSerialization.jsonObject(with: data, options: [])//конвертируем json
                    print(jsone)
                } catch {
                    print(error)
                }
            }
            
        }.resume()
        
        
        
    }
    
    
}

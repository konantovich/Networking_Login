//
//  AlamofireNetworkRequest.swift
//  Networking_Get_Post
//
//  Created by Antbook on 09.08.2021.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    
    static var onProgress : ((Double)->())?
    static var completed : ((String)->())?
    
    
    //делаем запрос с использованием  Alamofire .responseJSON
    static func sendRequestAlamofire (jsonUrlString: String, completion:  @escaping (_ apiStruct: [ApiStructAlamofire]) -> () ) {
        guard let url = URL(string: jsonUrlString) else {return}
   
        AF.request(url, method: .get).validate().responseJSON { responseJson in //response приходит массив
            
            switch responseJson.result {
            
            case .success(let value):
                print("value: ", value)
             
                
                guard let courses = ApiStructAlamofire.getArray(from: value) else {return}
                completion(courses)
                
            case .failure(let error):
                print("error: ", error)
            }
        }
    }
    
    
    //делаем запрос с использованием  Alamofire .responseData
    static func responseData (url: String) {
        
        AF.request(url).responseData { responseData in
            switch responseData.result {
            
            case .success(let data):
                
                guard let string = String(data: data, encoding: .utf8) else {return}
                
                print("responseData string: ", string)
                
            case .failure(let error):
                print("error responseData", error)
            }
        }
        
    }
    
    
    //делаем запрос с спользованием .responseString
    static func responseString (url: String) {
        
        AF.request(url).responseString { responseString in
            
            switch responseString.result {
            
            case .success(let data):
                print("responseString string: ", data)
            case .failure(let error):
                print("error responseString", error)
            }
        }
        
    }
    
    
    //делаем запрос с спользованием .response
    static func response (url: String) {
        AF.request(url).responseString { response in
            
            guard let data = response.data, let string = String(data: data, encoding: .utf8) else {return}
            
            print("response: ", string)
            
        }
    }
    
    
    
    //подключаем картинку по API через Alamofire
    func downloadImage (url: String, completion: @escaping (_ image: UIImage?)->()) {
        AF.request(url).responseData { responseData in
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else {return}
                
                completion(image)
                
            case .failure(let error):
                print("error", error)
            }
        }
    }
        
      
        static func downloadLargeImageAlamofireWithProgress (url: String, completion: @escaping (_ image: UIImage) -> ()) {
            
            guard let url = URL(string: url) else {return}
            
           
            //передаем данные в реальном времени
            AF.request(url).validate().downloadProgress { (progress) in
                print("progress:\(progress.totalUnitCount)")
                print("completedUnitCount", progress.completedUnitCount)
                print("fractionCompleted", progress.fractionCompleted)
                print("localizedDescription", progress.localizedDescription ?? "")
                print("---------------------------------------------------")
                self.onProgress?(progress.fractionCompleted)
                self.completed?(progress.localizedDescription)
            }.resume().response { response in
                
                guard let data = response.data, let image = UIImage(data: data) else {return}
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
         
        }
   
    //тоже самое что и  NetworkManager.postRequest выгружаем запрос, только через Alamofire
    static func postRequestAlamofire (jsonUrlString: String, completion:  @escaping (_ apiStruct: [ApiStructAlamofire]) -> () ) {
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        let userData : [String : Any] = [  "name": "Network Requests",
                                           "link": "https://swiftbook.ru/contents/our-first-applications/",
                                           "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                           "numberOfLessons": 18,
                                           "numberOfTests": 10  ]
        
        //отправляем на сервер и получаем ответ ввиде JSON в (responseJSON) приходит ответ
        AF.request(url, method: .post, parameters: userData).responseJSON { responseJSON in
            guard let statusCode = responseJSON.response?.statusCode else {return}
           
            print("statusCode: ", statusCode)
            
            switch responseJSON.result {
            
            case .success(let value):
                print(value)
                guard let jsonObject = value as? [String : Any] else {return}
                guard let courese = ApiStructAlamofire(json: jsonObject) else {return}
                
                var courses = [ApiStructAlamofire]()
                print("tests: ", courese.numberOfLessons)
                courses.append(courese)
                completion(courses)
                
            case .failure(let error):
                print("error: ", error)
            }
            
            
        }
        
        
        
        
    }
    
    
    //тоже самое что и  NetworkManager.postRequest выгружаем запрос, только через Alamofire
    static func putRequestAlamofire (jsonUrlString: String, completion:  @escaping (_ apiStruct: [ApiStructAlamofire]) -> () ) {
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        let userData : [String : Any] = [  "name": "Network Requests with Alamofire",
                                           "link": "https://swiftbook.ru/contents/our-first-applications/",
                                           "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                           "numberOfLessons": "18",
                                           "numberOfTests": "10"  ]
        
        //отправляем на сервер и получаем ответ ввиде JSON в (responseJSON) приходит ответ
        AF.request(url, method: .put, parameters: userData).responseJSON { responseJSON in
            guard let statusCode = responseJSON.response?.statusCode else {return}
           
            print("statusCode: ", statusCode)
            
            switch responseJSON.result {
            
            case .success(let value):
                print(value)
                guard let jsonObject = value as? [String : Any] else {return}
                guard let courese = ApiStructAlamofire(json: jsonObject) else {return}
                
                var courses = [ApiStructAlamofire]()
                courses.append(courese)
                completion(courses)
                
            case .failure(let error):
                print("error: ", error)
            }
            
            
        }
        
    }
    
    static func uploadImageWithAlamofire (url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Imagetest")! //named: - в ассетсах
        let data = image.pngData()!
        
        //айди с сервиса https://imgur.com/account/settings/apps
        let httpHeaders : HTTPHeaders = ["Authorization": "Client-ID f9529bd757695b7"]
        

        //способ закачки изображение только маленького объема (для видео не подойдет) 
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "image")
            
        }, to: url,
        headers: httpHeaders).validate().responseJSON { resp in
            switch resp.result {
            
            case .success(let value):
                print(value)
            case .failure(let error):
                print("error response to upload image:", error)
            }
            
            
            
        }
                 
    }

            
}

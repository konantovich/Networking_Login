//
//  MainViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 04.08.2021.
//

import UIKit
import UserNotifications //пуш уведомление пользователю
import FBSDKLoginKit


private let reuseIdentifier = "Cell"

class MainViewController: UICollectionViewController {

    let actions = ["Download Image", "GET", "POST", "Our Courses", "Upload Image", "Download file", "Our Courses Alamofire", "Response Data", "Response String", "Response", "LargeImageDownloadAlamofire", "Post with Alamofire", "Put Request", "Upload image with Alamofire"]
    
    private var networking = NetworkManager()
    private var dataProvider = DataProvider()
    private var filePath: String?  //отображение пути по которому будем сохранять файл

    
    
    let testApi = "https://swiftbook.ru/wp-content/uploads/api/api_courses"
    
    let url = "https://jsonplaceholder.typicode.com/posts"
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       checkLoggedIn()
        
        registerForNotification()//запрос у пользователя на отправку пуш уведомления (при первом запуске приложения)
        
        //запуститься после загрузки данных
        dataProvider.fileLocation = { location in
            
            //сохраняем файл для дальнейшого использование
            print("Download finish: \(location.absoluteString)")
            
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: false, completion: nil)
           
            self.postNotification()
        }
        
        
        
 
        
        
    }
    
    private var alert: UIAlertController!
    
    //настраиваем алерт загрузки
    private func showAlert() {
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        
        
        let height = NSLayoutConstraint(item: alert.view,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 0, constant: 170)
        alert.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { alert in
            self.dataProvider.stopDownload()
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true) {
            
            //ActivityIndicator
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - 20, y: self.alert.view.frame.height / 2 - 20)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            //ProgressView
            let progressView = UIProgressView(frame: CGRect(x: 0, y: self.alert.view.frame.height - 44, width: self.alert.view.frame.width, height: 2))
            progressView.tintColor = .blue
            //progressView.progress = 0.5
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
            }
            
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
            
        }
    }



//MARK: --UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return actions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.label.text = actions[indexPath.row]
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        
        switch action {
        case "Download Image" :
            performSegue(withIdentifier: "showImageSegue", sender: self)
        case "GET" :
            print("GET")
            networking.getRequest(url: url)
        case "POST" :
            print("POST")
            networking.postRequest(url: url)
        case "Our Courses" :
            performSegue(withIdentifier: "showOurCourses", sender: self)
        case "Upload Image" :
            print("Upload Image")
            networking.uploadImage(url: "https://api.imgur.com/3/image")
            
        case "Download file" :
            print("Download file")
            showAlert()
            dataProvider.startDownload()
        case "Our Courses Alamofire":
            print("Our Courses Alamofire")
            performSegue(withIdentifier: "showOurCoursesWithAlamofire", sender: self)
        case "Response Data":
            print("Response Data")
            performSegue(withIdentifier: "ResponseData", sender: self)
            AlamofireNetworkRequest.responseData(url: testApi)
        case "Response String":
            AlamofireNetworkRequest.responseString(url: testApi)
        case "Response":
            AlamofireNetworkRequest.response(url: testApi)
        case "LargeImageDownloadAlamofire":
            performSegue(withIdentifier: "LargeImage", sender: self)
        case "Post with Alamofire":
            performSegue(withIdentifier: "PostwithAlamofireSegue", sender: self)
        case "Put Request":
            performSegue(withIdentifier: "PutRequestSegue", sender: self)
        case "Upload image with Alamofire":
            AlamofireNetworkRequest.uploadImageWithAlamofire(url: "https://api.imgur.com/3/image")
            
        default:
            break
        }
        
    }
    
//MARK: -- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        let coursesVC = segue.destination as? MainTableViewController
        let imageVC = segue.destination as? ImageViewController
        
        switch segue.identifier {
        
        case "showImageSegue":
          
            imageVC?.fetchImage()
            
            print("imagevc")
            
        
        case "showOurCourses":
            print("kek")
            coursesVC?.networkManager.fetchData(jsonUrlString: coursesVC?.jsonUrlString ?? "") { courses in
                DispatchQueue.main.async {
                    print("COURSES !!!: ", courses)
                    coursesVC?.courses = courses
                    coursesVC?.tableView.reloadData()
                }
            }
        case "showOurCoursesWithAlamofire":
            print("Alamofire segue succes")
           // AlamofireNetworkRequest.sendRequest(url: url)
            coursesVC?.fetchDataWithAlamofire()
            
        case "ResponseData":
            print("ResponseData segue success")
            imageVC?.fetchDataWithAlamofire()
        case "LargeImage":
            print("LargeImage")
           
            imageVC?.downloadImageWithProgress()
            
        case "PostwithAlamofireSegue":
            print("PostwithAlamofireSegue")
            coursesVC?.postRequest()
        
        case "PutRequestSegue":
            print("PutRequestSegue")
            coursesVC?.putRequestWithAlamofire()
       
        default:
            break
        }
        
    }


}


//MARK: -- пуш уведомление о том что файл закачался
extension MainViewController {
    
    //запрос у пользователя на отправку пуш уведомления (при первом запуске приложения)
    private func registerForNotification () {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
        }
    }
    
    //создадим уведомление срабатывающее по времени
    private func postNotification () {
        let content = UNMutableNotificationContent() //объект контента
        content.title = "Download complete!"
        content.body = "Transfer has completed. File: \(filePath ?? "")"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false) //временной тригер срабатывания (через 3 сек после загрузки файла)
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger) //запрос с идентификатором, передаем сюда контент и тригер
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil) //запрос добавляем в центр нотификации
    }
    
}


//MARK: -- Facebook SDK
extension MainViewController {
    
    private func checkLoggedIn () {
        
        //if let token = AccessToken.current, !token.isExpired {}
        
        //проверяем активен ли токен авторизации пользователя
        if AccessToken.current == nil{
            print("The user is logout in")
            
            //если не активен то запускаем наш LoginViewController для логина 
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginVC, animated: false, completion: nil)
                return
            }
            
         }
    }
    
}

//
//  MainTableViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 02.08.2021.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    
    @IBOutlet var mainTableView: UITableView!
    var courses = [ApiStructAlamofire]()

    
    private var courseName : String?
    private var courseUrl : String?
    
    private var postRequestUrl = "https://jsonplaceholder.typicode.com/posts"
    
    private var putRequest = "https://jsonplaceholder.typicode.com/posts/1"
    
    var networkManager = NetworkManager()
    
    // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_course"
    let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_courses"
    // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_website_description"
    // let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_missing_or_wrong_fields"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
            
        }
        
       //Alamofire responseJSON
    func fetchDataWithAlamofire () {
        AlamofireNetworkRequest.sendRequestAlamofire(jsonUrlString: jsonUrlString) {courses in
            DispatchQueue.main.async {
                self.courses = courses
                self.tableView.reloadData()
        }
        
    }
    }
    
    //Alamofire responseData
    func fetchDataWithAlamofireResponseData () {
        AlamofireNetworkRequest.responseData(url: jsonUrlString)
    }
    
    
    func postRequest () {
        AlamofireNetworkRequest.postRequestAlamofire(jsonUrlString: postRequestUrl ) { courses in
            
            self.courses = courses
            
            DispatchQueue.main.async {
             
            self.tableView.reloadData()
            }
        }
       
    }
    
    func putRequestWithAlamofire() {
        
        AlamofireNetworkRequest.putRequestAlamofire(jsonUrlString: putRequest) { courses in
            
            self.courses = courses
            DispatchQueue.main.async {
             
            self.tableView.reloadData()
            }
            
        }
        
        
    }
        
        
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courses.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let course = courses[indexPath.row]
        
        cell.nameLabel.text = course.name
        //  cell.labelLabel.text = course.link
        
        
        if let numberOfLessons = course.numberOfLessons{
            cell.numberLabel.text = "Number of lessons: \(numberOfLessons)"
        }
        
        if let numberOfTests = course.numberOfTests {
            cell.labelLabel.text = "Number of tests: \(numberOfTests)"
        }
        
        DispatchQueue.global().async {
            let imageUrl = URL(string: course.imageUrl)!
            let imageData = try? Data(contentsOf: imageUrl)
            
            DispatchQueue.main.async {
                cell.courseImage.image = UIImage(data: imageData!)
                cell.courseImage.contentMode = .scaleAspectFill
                
            }
        }
        
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webVC = segue.destination as! WebViewController
        webVC.selectedCourse = courseName
        
        if let url = courseUrl {
            webVC.courseURL = url
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let course = courses[indexPath.row]
        
        courseUrl = course.link
        courseName = course.name
        
        performSegue(withIdentifier: "Description", sender: self)
        
        
    }
    
}

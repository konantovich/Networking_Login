//
//  ImageViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 01.08.2021.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var networkManager = NetworkManager()
    
    var imageUrl = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    
    let urlImage = "https://i.imgur.com/rPlQ1EL.png"//"https://i.imgur.com/3416rvI.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.completedLabel.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        
        self.completedLabel.isHidden = true
        self.progressView.isHidden = true
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    
    //подключаем картинку по API через URLSession
    func fetchImage () {
        networkManager.downloadImage(url: imageUrl) { image in
            
            self.activityIndicator.isHidden = true
            self.imageView.image = image
            self.activityIndicator.stopAnimating()
        }
    }
    
    //подключаем картинку по API через Alamofire (.responseData)
    func fetchDataWithAlamofire () {
        
        networkManager.downloadImage(url: imageUrl) { image in
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
        }
        
    }
    
    
    func downloadImageWithProgress() {
        print(".downloadLargeImageAlamofireWithProgress")
        AlamofireNetworkRequest.onProgress = { progress in
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
            if progress == 1.0 {
                self.progressView.isHidden = true
                self.completedLabel.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        }
        
        AlamofireNetworkRequest.completed = { completion in
            self.completedLabel.isHidden = false
            self.completedLabel.text = completion.description
            
        }
        
        AlamofireNetworkRequest.downloadLargeImageAlamofireWithProgress(url: urlImage) { image in
            self.activityIndicator.stopAnimating()
            self.imageView.image = image
            
        }
    }
    
    
    
    
}

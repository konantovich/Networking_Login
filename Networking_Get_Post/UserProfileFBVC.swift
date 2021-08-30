//
//  UserProfileFBVC.swift
//  Networking_Get_Post
//
//  Created by Antbook on 20.08.2021.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileFBVC: UIViewController {

    @IBOutlet weak var loginUserLabel: UILabel!
    @IBOutlet weak var loginUserActivityIndicator: UIActivityIndicatorView!
    
    private var provider: String? //поймем при помощи какого провайдера авторизован пользователь
    private var currentUser: CurrentUserFromFirebase? //обращаемся к нашей моделе
    
    
    lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32, y: view.frame.height - 256, width: view.frame.width - 64, height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)

        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        loginUserLabel.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    //в отличие от viewDidLoad() метод viewWillAppear вызывается при каждом появлении экрана
    override func viewWillAppear(_ animated: Bool) {
        fetchingUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
      
    }
    
    private func setupViews () {
        view.addSubview(logOutButton)
    }


}



extension UserProfileFBVC {
 
    //открываем контроллер авторизации пользователя если он не залогинен
    private func  openLoginViewController () {
        //if let token = AccessToken.current, !token.isExpired {}
        
        //проверяем активен ли токен авторизации пользователя
      
            print("The user is logout in")
            
            //если не активен то запускаем наш Storyboard / LoginViewController для логина на фейсбук(в основном потоке)
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginVC, animated: true, completion: nil)
                return
            }
            
         
    }
    
    
    //получаем данные с FirebaseDataBase и отображаем полученные данные на экране
    private func fetchingUserData() {
        
        //убедились что наш юзер залогиненый в Firebase (через базу данных)
        if Auth.auth().currentUser != nil {
            
            //но в других входах мы не добавляли после логина в БД, по этому будем находить по Username в Firebase
            if let userName = Auth.auth().currentUser?.displayName {
                
                self.loginUserActivityIndicator.stopAnimating()
                self.loginUserLabel.isHidden = false
                self.loginUserLabel.text = "Hello \(userName) from \(getProviderData())"
                
            } else { //если Username пустой то обращаемся к БД
                
                //берем айди юзера
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                //обращаемся к директориям БД Firebase и запрашиваем данные ввиде словаря
                Database.database().reference()
                    .child("users")
                    .child(uid)
                    .observeSingleEvent(of: .value) { screenDataBase in
                      //screenDataBase работа со снимком базы данных, положим данные в словарь [String: Any]
                        guard let userData = screenDataBase.value as? [String: Any] else {return}
                        
                        self.currentUser = CurrentUserFromFirebase(uid: uid, data: userData)
                        
                        self.loginUserActivityIndicator.stopAnimating()
                        self.loginUserLabel.isHidden = false
                        self.loginUserLabel.text = self.getProviderData() //функция с возвратом нужной строки
                 
                        
                    } withCancel: { error in
                            print("error fetch firebase: ", error)
                    }
            }
        }
    }
    
    //общая кнопка логаута
    @objc private func signOut () {
        
        //нужно понять с какого провайдера залогонился юзер (google facebook итд)
        if let providerData = Auth.auth().currentUser?.providerData {
           
            
            //providerData это [UserInfo], данный тип имеет юзер айди, в зависимости от того какое ID имеет пользователь нам нужно делать доавторизацию из той или инной сети
            for userInfo in providerData {
                switch userInfo.providerID {
                   //нам нужно перебрать все варианты возможнолого логина и выйти
                case "facebook.com" :
                    LoginManager().logOut()
                    print("log Out Facebook success")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("log Out Google success")
                    openLoginViewController()
                case "password":
                    try! Auth.auth().signOut()
                    print("log Out Firebase succes")
                    openLoginViewController()
                default:
                    //userInfo.providerID пишет название провайдера для входа, например "facebook.com"
                    print("User sign in with \(userInfo.providerID)")
                    
                    
                }
            }
            
        }
    }
    
    
    //метод что бы определить провайдера (к которому залогинились) и дальше отправить данные например Label и тд
    private func getProviderData () -> String {
        
        var helloMessage = ""
        
        //узнаем провайдера и присваиваем провайдеру значение
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com" :
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                case "password":
                    provider = "Email"
                default:
                    break
                }
                
            }
            //полученное присваиваем в helloMessage и так как функция возвращает String, она вернет нам строку с данными залогиненного провайдера
            helloMessage = "\(provider!)"
            
        }
        return helloMessage
        
    }
 
    
}

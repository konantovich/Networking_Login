//
//  LoginViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 19.08.2021.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn


class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
 
 
    
    //кнопка логина в гугл (классическая)
    lazy var googleLoginButton: GIDSignInButton = {
        let loginButton = GIDSignInButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        
        
        return loginButton
    }()
    
    //кнопка логина в гугл (custom)
    lazy var googleLoginButtonCustom: UIButton = {
       let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.backgroundColor = .white
        loginButton.setTitle("Google Login button Custom", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.setTitleColor(.gray, for: .normal)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleGoogleLoginCustom), for: .touchUpInside)
        
        return loginButton
        
        
    }()
    
    //кнопка логина на фейсбук (классическая)
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        
        return loginButton
    }()
    
    
    //custom кнопка логина на фейсбук
    lazy var customFBLoginButton: UIButton = {
       let loginButton = UIButton()
        
        //свойство из нашего Extension, можем подставлять цвет без инициализации RGB значений
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Custom Button, Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFacebookLogin), for: .touchUpInside)
        
        return loginButton
    }()
    
    
    //кнопка логина через Email
    lazy var emailLoginButtom: UIButton = {
        let loginButton = UIButton()
        
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Email login", for: .normal)
        loginButton.addTarget(self, action: #selector(handleEmailLogin), for: .touchUpInside)
        
        return loginButton
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
       setupViews()
        // Do any additional setup after loading the view.

            
    }
    
    
    private func setupViews () {
        self.view.addSubview(fbLoginButton)
        self.view.addSubview(customFBLoginButton)
        self.view.addSubview(googleLoginButton)
        self.view.addSubview(googleLoginButtonCustom)
        self.view.addSubview(emailLoginButtom)
    }
    


}


//MARK: -- Facebook SDK

//протокол для отслеживания успешного логина и логаута через facebook
extension LoginViewController: LoginButtonDelegate {
    //отслеживает авторизацию пользователя(логин)
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            print("Ошибка входа на фейсбук, причина: ", error)
            return
        }
        print("Success logged in with Facebook: ")
        
        //проверяем что пользователь залогинился
        guard AccessToken.current != nil else {return}
        
        self.singInToFirebase()
          
    }
    
    //позволяет отслеживать логаут пользователя
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did log out facebook")
    }
    
    
    //возвращаемся в основной MainViewController после логина
    private func openMainViewController () {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //по нажатию на custom facebook login button будем логиниться
    @objc private func handleCustomFacebookLogin () {
        
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { result, error in
            
            if let error = error {
                print("error: ", error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            //если пользователь отменил, то выходим. Если нажал продолжить то открываем наш VC
            if result.isCancelled {return} else {
                self.singInToFirebase()
                
            }
            
        }
        
    }
    
    //подключаем/авторизируем пользователя Facebook в Firebase/Auth
    private func singInToFirebase() {
        
       
        let accesToken = AccessToken.current
        guard let accessTokenString = accesToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        //настраиваем фаербейс
        Auth.auth().signIn(with: credentials) { user, error in
            
            if let error = error {
                print("Error with our facebook user: ", error)
                return
            }
            
            print("Success logged facebook user")
            
            self.fetchFacebookFields ()
            
            
            
        }
    }
    
    
    //получаем данные с Facebook и парсим
    private func fetchFacebookFields () {
        //запросили данные у Facebook
        GraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"]).start { _, result, error in
            if let error = error {
                print(error)
                return
            }
            
            //получим раньше чем этот пользователь попадет на firebase
            if let userData = result as? [String : Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                print("name user logged: ",self.userProfile?.name ?? "nil")
                self.saveIntoFirebase()
                
            }
        }
    }
    
    
    //отправляем в firebase (настроили сохранение в базе данных firebase)
    private func saveIntoFirebase () {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        let values = [uid: userData]
        
        print("uid firebase: ",userData)
        
        
    
        Database.database().reference().child("users").child(uid).setValue(["test":"lolkek"])
   
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in //обновить значение в директории (с нашим словарем)
           
                if let error = error {
                    print("error firebase database add value: ", error)
                    return
                }
                
                print("success add to firebase Data Base")
                self.openMainViewController()
            }
        
    }
    
}
    
//MARK: -- Google SDK
     
extension LoginViewController {
    
    
    @objc func handleGoogleLogin () {
        print("handleGoogleLogin")
        
        userGoogleSingIn()
        
    }
    
    //Настраиваем вход через гугл
    private func userGoogleSingIn (){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
       
        print(config)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            

          if let error = error {
            print("google sign in error: ", error)
            return
          }
            
            print("success logged into google")
            
    
            if let userName = user?.profile?.name, let userEmail = user?.profile?.email {
               
                let userData = ["name": userName, "email": userEmail]
                
                userProfile = UserProfile(data: userData)
            }
            
            //результат авторизации пользователя в Google
          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }
            
            //для дальнейшей регистриции пользователя в Firebase
          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
      
            Auth.auth().signIn(with: credential) { user, error in
                if let error = error {
                    print("Error auth google in Firebase :", error)
                    return
                }
                
                print("Success logged into Firebase with google")
               saveIntoFirebase()
                
                
                
            }
        }
    }
    
    
    
  
    @objc func handleGoogleLoginCustom () {
        print("handleGoogleLoginCustom")
        
        userGoogleSingIn()
    }
    
   
    @objc func handleEmailLogin () {
        performSegue(withIdentifier: "signInSegue", sender: self)
    }
    
    
}


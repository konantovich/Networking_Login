//
//  SignInViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 28.08.2021.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    
    
    lazy var continueButton : UIButton = {
        let button = UIButton()
        
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: view.center.x, y: view.center.y + 200)
        button.backgroundColor = .white
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.brown, for: .normal)
        button.layer.cornerRadius = 4
        button.alpha = 0.5//приглушили альфой кнопку (до ввода логина пароля)
        button.addTarget(self, action: #selector(hendleContinueButton), for: .touchUpInside)
        
        return button
    }()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.isSecureTextEntry = true
        
        setContinueButton(enable: false)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
        
        emailTextField.addTarget(self, action:  #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        view.addSubview(activityIndicator)
        view.addSubview(continueButton)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //отслеживаем появление клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillApear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        activityIndicator.center = continueButton.center
        
    }
    
    //когда появляется клавиатура, поднимается вместе с ней кнопка Continue
    @objc func keyboardWillApear (notification: NSNotification) {
        
        //определяем габариты и расположение и габариты клавиатуры
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityIndicator.center = continueButton.center
    }
    
    //отвечает за доступность кнопки Continue
    private func setContinueButton (enable: Bool) {
        if enable {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    //входим кнопкой Continue
    @objc func hendleContinueButton () {
        setContinueButton(enable: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error {
                print("Error login into Firebase: ", error.localizedDescription)
                
                //кнопка опять Continue не активна
                self.setContinueButton(enable: true)
                self.continueButton.setTitle("Continue", for: .normal)
                self.activityIndicator.stopAnimating()
                self.errorLabel.text = "Try again, reason: \(error.localizedDescription)"
                
                return
            }
            print("Login into Firebase success")
            
            //удаляем стеки открытых ViewController'ов (сейчас открыто 2 контролера)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
       
            
        }
        
        
    }
    
    //отслеживает работу с текстовыми полями (активация доступа к кнопке Continue)
    @objc func textFieldChanged () {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        let formFilled = !(email.isEmpty) && !(password.isEmpty)
        
        setContinueButton(enable: formFilled)
      
        
        
        
        
    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
}

//
//  SignUpViewController.swift
//  Networking_Get_Post
//
//  Created by Antbook on 28.08.2021.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController {


    var activityIndicator: UIActivityIndicatorView! //крутилка будет крутиться на кнопке Continue пока ждем ответ сервера
    
    //создали кнопку программно, что бы можно было ее поднимать (в зависимости от клавиатуры)
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
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
        
        
        
        setContinueButton(enable: false)
        
        userNameTextField.addTarget(self, action:  #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action:  #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action:  #selector(textFieldChanged), for: .editingChanged)
        
        view.addSubview(continueButton)
        view.addSubview(activityIndicator)
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
        //при появлении клавиатуры, по y высота экрана минус высота клавиатуры, минус половина высоты кнопки Continue
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
    
    
    @objc func hendleContinueButton () {
        setContinueButton(enable: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let userName = userNameTextField.text else {return}
        
        //Регистрируем пользователя в Firebase
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            
            //
            if let error = error {
                print(error.localizedDescription)// .localizedDescription объяснение ошибки Firebase
                
                //кнопка опять Continue не активна
                self.setContinueButton(enable: true)
                self.continueButton.setTitle("Continue", for: .normal)
                self.activityIndicator.stopAnimating()
                self.errorLabel.text = "Try again, reason: \(error.localizedDescription)"
                
                return
            }
            
            //если ошибки нет то пользователь автоматически добавился в Firebase
            print("Success add user into Firebase")
            
            //даллее можно изменять пользователя на Firebase
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                changeRequest.displayName = userName
                
                //подтверждаем изменения
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error change user into Firebase: ", error.localizedDescription)
                        
                        //кнопка опять Continue не активна
                        self.setContinueButton(enable: true)
                        self.continueButton.setTitle("Continue", for: .normal)
                        self.activityIndicator.stopAnimating()
                        
                        return
                    }
                    print("User name changed")
                    
                    //удаляем стеки открытых ViewController'ов (сейчас открыто 3 контролера)
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
               
                }
            }
            
            
        }
        
    }
    
    //отслеживает работу с текстовыми полями (активация доступа к кнопке Continue)
    @objc func textFieldChanged () {
        //если поля текстовых полей не пустые, то открываем доступ к кнопке Continue (или если пустое то закрываем доступ) и если пароль равен подтверждение пароля
        guard let userName = userNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else {return}
        let formFilled = !(userName.isEmpty) && !(email.isEmpty) && !(password.isEmpty) && !(confirmPassword.isEmpty) && password == confirmPassword
        
        setContinueButton(enable: formFilled)
    }

}

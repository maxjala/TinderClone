//
//  LoginViewController.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.addTarget(self, action: #selector(directToSignUp), for: .touchUpInside)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Auth.auth().currentUser) != nil {
            print("User already logged in")
            
            User.generateCurrentUser(completion: { (user) in
                
                DispatchQueue.main.async {
                    UserDefaults.saveGenderPreference(user.preference)
                    UserDefaults.saveUserGender(user.gender)
                    UserDefaults.saveUserName(user.name)
                    UserDefaults.saveUserLikes(user.likedPeople)
                }
                self.directToMain(user)
                
            })
            
        }
        
    }

    func loginButtonTapped () {
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else { return }
        
        if email == "" || password == "" {
            print ("input error : email / password cannot be empty")
            return
        }
        
        //paste from Sign in existing users in Authentication
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // ...
            if let err = error {
                print("SignIn Error : \(err.localizedDescription)")
                return
            }
            
            guard let user = user
                else {
                    print("User Error")
                    return
            }
            
            print("User Logged In")
            print("email : \(String(describing: user.email))")
            print("uid : \(user.uid)")
            
            DispatchQueue.main.async {
                
                User.generateCurrentUser(completion: { (user) in
                    
                    UserDefaults.saveGenderPreference(user.preference)
                    UserDefaults.saveUserGender(user.gender)
                    UserDefaults.saveUserName(user.name)
                    UserDefaults.saveUserLikes(user.likedPeople)
                    self.directToMain(user)
                    
                })
                
            }

        }
    }
    
    func directToMain(_ user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        vc?.currentUser = user
        present(navController, animated: true, completion: nil)
    }
    
    func directToSignUp() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    
}

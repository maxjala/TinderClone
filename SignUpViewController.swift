
//
//  SignUpViewController.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        //self.hideKeyboardWhenTappedAround()
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func signUpTapped() {
        guard let email = emailTextField.text,
            let password = passWordTextField.text,
            let confirmPassword = confirmPasswordTextField.text else {return}
        
        if email == "" || password == "" || confirmPassword == "" {
            print("Email / password cannot be empty")
        }
        
        if password != confirmPassword {
            print("Passwords do not match");
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/chatapp2-8fc6d.appspot.com/o/icon1.png?alt=media&token=a0c137ff-3053-442b-a6fb-3ef06f818d6a"
            
            if error != nil {
                return
            }
            
            guard let user = user
                else {
                    print ("User not created error")
                    return
            }
            
            print("User ID \(user.uid) with email: \(String(describing: user.email)) created")
            
            let post : [String : Any] = ["id": user.uid, "email": user.email!, "pictureArray" : [defaultImageURL]]
            self.ref.child("users").child("\(user.uid)").updateChildValues(post)
            
            self.directToDetailViewController(defaultImageURL)
        }
    }
    
    func directToDetailViewController(_ defaultImage: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier:"EditProfileViewController") as! EditProfileViewController
        viewController.displayType = .signUp
        viewController.userPicURLArray = [defaultImage]
        present(viewController, animated: true, completion: nil)
    }
}


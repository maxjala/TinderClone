//
//  DetailSignUpViewController.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class DetailSignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var preferenceSegmentControl: UISegmentedControl!
    
    
    @IBOutlet weak var uploadButton: UIButton! {
        didSet {
            uploadButton.addTarget(self, action: #selector(uploadDisplayPictureButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    var currentUser = Auth.auth().currentUser
    var currentUserID : String = ""
    var newProfileImageURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        if let id = currentUser?.uid {
            print(id)
            currentUserID = id
        }
        
        //self.hideKeyboardWhenTappedAround()
    }
    
    func signUpButtonTapped () {
        
        let preferenceString = preferenceSegmentControl.titleForSegment(at: preferenceSegmentControl.selectedSegmentIndex)!
        let modifiedString = preferenceString.replacingOccurrences(of: "e", with: "a")
        
        let post : [String : String] = ["userName": nameTextField.text!, "bio" : bioTextView.text, "gender": genderSegmentControl.titleForSegment(at: genderSegmentControl.selectedSegmentIndex)!, "preference": modifiedString]
        
        self.ref.child("users").child("\(currentUserID)").updateChildValues(post)
        
        UserDefaults.saveGenderPreference(modifiedString)
        UserDefaults.saveUserGender(genderSegmentControl.titleForSegment(at: genderSegmentControl.selectedSegmentIndex)!)
        UserDefaults.saveUserName(nameTextField.text!)
        UserDefaults.saveUserLikes([])
        self.directToMainViewController()
    }
    
    func directToMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier:"NavigationController") as! UINavigationController
        self.present(viewController, animated: true)
    }
    
    func uploadDisplayPictureButtonTapped () {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func dismissimagePicker () {
        dismiss(animated: true, completion: nil)
    }
    
    let dateFormat : DateFormatter = {
        
        let _dateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        _dateFormatter.locale = locale
        _dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return _dateFormatter
    }()
    
    func uploadImage (_ image: UIImage) {
        
        let ref = Storage.storage().reference()
        
        //convert image to data
        guard let imageData = UIImageJPEGRepresentation(image, 0.5)
            else { return }
        let metaData = StorageMetadata ()
        
        metaData.contentType = "image/JPEG"
        
        ref.child(uniqueFileForUser("Max")).putData(imageData, metadata: metaData) {
            (meta, error) in
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                
                //save to Firebase
                self.saveImagePath(downloadPath)
                self.newProfileImageURL = downloadPath
                
                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: self.newProfileImageURL)
            }
        }
    }
    
    func saveImagePath (_ path: String) {
        
        let imageValue : [String: Any] = ["imageURL": path]
        
        ref.child("users").child(currentUserID).updateChildValues(imageValue)
        
    }
    
    //End of DetailViewController
}

extension DetailSignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate { //cannot put variable inside
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //dismiss once you finish
        defer {
            dismissimagePicker()
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { return }
        
        //display and store
        self.uploadImage(image)
    }
    
    //create unique file name
    func uniqueFileForUser (_ name : String) -> String {
        
        let currentDate = Date()
        return"\(name)_\(currentDate.timeIntervalSince1970).jpeg"
    }
    
    func downloadImage (_ reference: String) {
        let storageRef = Storage.storage().reference()

        storageRef.child(reference).getData(maxSize: 1*102*1024) { (data, error) in _ =
            UIImage(data: data!)
        }
    }
    
    func observeImage () {
        let dbRef = Database.database().reference().child("chat")
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            let chatDictionary = snapshot.value as? [String: Any]
            if let refPath = chatDictionary?["referencePath"] as? String {
                self.downloadImage(refPath)
            }
        })
    }
    
    //End of extension
}

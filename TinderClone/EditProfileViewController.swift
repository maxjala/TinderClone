//
//  EditProfileViewController.swift
//  TinderClone
//
//  Created by Max Jala on 28/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase

enum DisplayType {
    case signUp
    case editProfile
}

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.isHidden = true
        }
    }
    
    @IBOutlet weak var imageView1: UIImageView! {
        didSet {
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "0"
            imageView1.isUserInteractionEnabled = true
            imageView1.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var imageView2: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "1"
            imageView2.isUserInteractionEnabled = true
            imageView2.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var imageView3: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "2"
            imageView3.isUserInteractionEnabled = true
            imageView3.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var imageView4: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "3"
            imageView4.isUserInteractionEnabled = true
            imageView4.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var imageView5: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "4"
            imageView5.isUserInteractionEnabled = true
            imageView5.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var imageView6: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(enableImagePicker))
            tapGestureRecognizer.accessibilityHint = "5"
            imageView6.isUserInteractionEnabled = true
            imageView6.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var preferenceSegControl: UISegmentedControl!
    
    @IBOutlet weak var genderSegControl: UISegmentedControl!

    @IBOutlet weak var saveChangesButton: UIButton! {
        didSet {
            saveChangesButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        }
    }
    
    var displayType: DisplayType = .editProfile
    
    var ref: DatabaseReference!
    var authUser = Auth.auth().currentUser
    var currentUserID : String = ""
    var currentUser : User?
    var imageViewTag : Int?
    var userPicURLArray : [String] = []
    var profileWasChanged = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = Database.database().reference()
        if let id = authUser?.uid {
            currentUserID = id
        }
        
        //fetchAndLoadPics()
        configureDisplayType()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configureDisplayType() {
        if displayType == .editProfile {
            fetchAndLoadPics()
            
            bioTextView.text = currentUser?.bio
            
            if currentUser?.gender == "Man" {
                genderSegControl.selectedSegmentIndex = 0
            } else if currentUser?.gender == "Woman" {
                genderSegControl.selectedSegmentIndex = 1
            }
            
            if currentUser?.preference == "Man" {
                preferenceSegControl.selectedSegmentIndex = 0
            } else if currentUser?.preference == "Woman" {
                preferenceSegControl.selectedSegmentIndex = 1
            } else {
                preferenceSegControl.selectedSegmentIndex = 2
            }
            
        } else {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            nameTextField.isHidden = false
        }
    }

    func fetchAndLoadPics() {
        if userPicURLArray.count == 6 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            imageView2.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[1])
            imageView3.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[2])
            imageView4.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[3])
            imageView5.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[4])
            imageView6.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[5])
        } else if userPicURLArray.count == 5 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            imageView2.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[1])
            imageView3.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[2])
            imageView4.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[3])
            imageView5.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[4])
        } else if userPicURLArray.count == 4 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            imageView2.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[1])
            imageView3.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[2])
            imageView4.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[3])
        } else if userPicURLArray.count == 3 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            imageView2.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[1])
            imageView3.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[2])
            
        }else if userPicURLArray.count == 2 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
            imageView2.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[1])
            
        } else {
            imageView1.loadImageUsingCacheWithUrlString(urlString: userPicURLArray[0])
        }

    }

    func saveButtonTapped() {

        let preferenceString = preferenceSegControl.titleForSegment(at: preferenceSegControl.selectedSegmentIndex)!
        let modifiedString = preferenceString.replacingOccurrences(of: "e", with: "a")

        UserDefaults.saveGenderPreference(modifiedString)
        UserDefaults.saveUserGender(genderSegControl.titleForSegment(at: genderSegControl.selectedSegmentIndex)!)
        
        if displayType == .signUp {
            UserDefaults.saveUserName(nameTextField.text!)
            UserDefaults.saveUserLikes([])
            let post : [String : Any] = ["userName": nameTextField.text!, "bio" : bioTextView.text, "gender": genderSegControl.titleForSegment(at: genderSegControl.selectedSegmentIndex)!, "preference": modifiedString, "pictureArray": userPicURLArray]
            self.ref.child("users").child(currentUserID).updateChildValues(post)
            directToMainViewController()
            
            
        } else {
            let post : [String:Any] = ["bio" : bioTextView.text, "gender": genderSegControl.titleForSegment(at: genderSegControl.selectedSegmentIndex)!, "preference": modifiedString, "pictureArray": userPicURLArray]
            self.ref.child("users").child(currentUserID).updateChildValues(post)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    func directToMainViewController() {
        let viewController = storyboard?.instantiateViewController(withIdentifier:"NavigationController") as! UINavigationController
        self.present(viewController, animated: true)
    }
    
    
    func enableImagePicker(_ sender: UITapGestureRecognizer) {
        let senderTag = Int(sender.accessibilityHint!)
        imageViewTag = senderTag
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func dismissImagePicker() {
        dismiss(animated: true, completion: nil)
    }

    func uploadImage(_ image: UIImage) {
        
        let ref = Storage.storage().reference()
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        ref.child("\(currentUserID)-\(Date().timeIntervalSince1970).jpeg").putData(imageData, metadata: metaData) { (meta, error) in
            
            if let downloadPath = meta?.downloadURL()?.absoluteString {
                
                self.loadImageBasedOnTag(downloadPath)
                
            }
        }
    }

    func loadImageBasedOnTag(_ imageURL: String) {
        
        if imageViewTag == 5 {
            imageView6.loadImageUsingCacheWithUrlString(urlString: imageURL)
        } else if imageViewTag == 4 {
            imageView5.loadImageUsingCacheWithUrlString(urlString: imageURL)
        } else if imageViewTag == 3 {
            imageView4.loadImageUsingCacheWithUrlString(urlString: imageURL)
        } else if imageViewTag == 2 {
            imageView3.loadImageUsingCacheWithUrlString(urlString: imageURL)
        } else if imageViewTag == 1 {
            imageView2.loadImageUsingCacheWithUrlString(urlString: imageURL)
        } else if imageViewTag == 0 {
            imageView1.loadImageUsingCacheWithUrlString(urlString: imageURL)
        }
        
        userPicURLArray = updateUserPicsArray(userPicURLArray, imageURL: imageURL)
        
    }
    
    func updateUserPicsArray(_ picArray: [String], imageURL: String) -> [String] {
        var pics = picArray
        
        if pics.count > imageViewTag! {
            pics[imageViewTag!] = imageURL
        } else {
            pics.append(imageURL)
        }
        return pics
    }
    
}


extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismissImagePicker()
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        //display / store
        uploadImage(image)
        
    }
    
}
 

//
//  CreateAccountViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 11/22/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//


import UIKit
import Firebase
class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    //UI objects
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var nameLineView: UIView!
    @IBOutlet weak var pictureViewContainer: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountContainer: UIView!
    @IBOutlet weak var screenScrollView: UIScrollView!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // Variables
    var profilePicProvided = false
    //Actions
    @IBAction func createAccountPressed(_ sender: UIButton) {
        //bring down keyboard
        self.view.endEditing(true)
        //check to see if there are values in each of the required sections.
        createAccountButton.isEnabled = false
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            self.indicateProblem()
            createAccountButton.isEnabled = true
            nameTextField.text = "one of the fields was not filled out"
            return}
        //start the load inidcator
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        //authenticate user with email and password.
        Auth.auth().createUser(withEmail: email, password: password) { (FIRUser, problem) in
            if problem != nil {
                print(problem!)
                stopProcess()
                
                return
            }
            guard let userIdentification = FIRUser?.uid else {
                stopProcess()
                return
            }
            //Upload profile picture into storage
            let uniqueImageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("Profile Pictures").child("Profile Pic (ID: \(uniqueImageName))")
            if self.profilePicProvided {
                //turn selected photo into JPEG (smaller file)
                guard let dataToUpload = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) else {
                    print("photo data could not be unwrapped"); return
                }
                //upload the given photo
                storageRef.putData(dataToUpload, metadata: nil, completion: { (myData, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let profileImageURL = myData?.downloadURL()?.absoluteString {
                        let valueList = ["name": name, "email": email, "profileImageURL": profileImageURL]
                        self.registerUserToDatabase(userID: userIdentification, values: valueList)
                    }
                })
            }
            else {
                //set profile pic to nil
                let valueList = ["name": name, "email": email, "profileImageURL": "nil"]
                self.registerUserToDatabase(userID: userIdentification, values: valueList)
            }
            
        }
        
        
        func stopProcess() {
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
            self.indicateProblem()
            createAccountButton.isEnabled = true
        }
    }
    
    func registerUserToDatabase(userID: String, values: [String: Any]) {
        //Create a reference to the new user (with unique ID) in the database
        let userReference = DBRef.child("Users").child(userID)
        //add name and email to that ID
//
        userReference.updateChildValues(values, withCompletionBlock: { (error, DBRef) in
            if error != nil {
                print(error!)
                return
            }
            
            print("New User Save Successful")
            //enable button again
            self.createAccountButton.isEnabled = true
            //If all is well, transition to the tutorial
            self.performSegue(withIdentifier: "toTutorial", sender: self)
        })
    }
    
    
    //Lower keyboard when background is tapped
    @IBAction func backgroundTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //Add profile image
    @IBAction func editPicturePressed(_ sender: UIButton) {
       //Set controller for image choosing process
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //initiializes alert controller with three actions: take photo, choose photo, and cancel.
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default, handler: {action in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        })
            
          alertController.addAction(takePhoto)
        }
        let choosePhoto = UIAlertAction(title: "Choose From Library", style: .default, handler: {action in
        imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            
        })
        alertController.addAction(cancelAction)
        
        alertController.addAction(choosePhoto)
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       //downcast chosen image taken from outside of the app to a UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = editedImage
            profilePicProvided = true
            //dismisses photo chooser
            dismiss(animated: true, completion: nil)
        }
       else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //set this image to the shown profile image
            profileImageView.image = originalImage
            profilePicProvided = true
            //dismisses photo chooser
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //reinstates the nav controller (this might need some work). Sets the corner radius on UI objects
        loadingIndicator.isHidden = true
        navigationController?.navigationBar.isHidden = false
        emailLineView.layer.cornerRadius = 3
        passwordLineView.layer.cornerRadius = 3
        nameLineView.layer.cornerRadius = 3
        pictureViewContainer.clipsToBounds = true
        pictureViewContainer.layer.cornerRadius = 90

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func indicateProblem() {
        //Visual cue to tell user that a problem has occurred. Maybe add in an explanation with the error message later
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.createAccountContainer.backgroundColor = .red
        }, completion: { (success) in
            self.createAccountContainer.backgroundColor = .white
        })
    }
    //Raises view to accomidate the presence of the keyboard
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let keyboardOffset: CGPoint = CGPoint(x: 0, y: 150)
        screenScrollView.setContentOffset(keyboardOffset, animated: true)
    }
    //Lowers view after keyboard retracts
    func textFieldDidEndEditing(_ textField: UITextField) {
        let keyboardOffset: CGPoint = CGPoint(x: 0, y: 0)
        screenScrollView.setContentOffset(keyboardOffset, animated: true)
    }

    //Sets function for the return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

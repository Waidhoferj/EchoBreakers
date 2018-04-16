//
//  LoginViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 11/22/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.



import UIKit
import Firebase
class LoginViewController: UIViewController, UITextFieldDelegate {
    //UI objects
    @IBOutlet weak var emailLineView: UIView!
    @IBOutlet weak var passwordLineView: UIView!
    @IBOutlet weak var loginScrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    
    //Variables
    

    
    @IBAction func signInPressed(_ sender: UIButton) {
        //bring down keyboard
        self.view.endEditing(true)
        //disable button to protect from double sign in
        signInButton.isEnabled = false
        //enable loading wheel
        loadingWheel.isHidden = false
        loadingWheel.startAnimating()
        //add first time login function later to trigger survey
        //sign in user:
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, issue) in
            if issue != nil {
                print(issue!)
                self.signInButton.isEnabled = true
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                    self.emailLineView.backgroundColor = .red
                    self.passwordLineView.backgroundColor = .red
                }, completion: { (success) in
                    self.emailLineView.backgroundColor = .white
                    self.passwordLineView.backgroundColor = .white
                })
                self.loadingWheel.stopAnimating()
                self.loadingWheel.isHidden = true
                return
            }
            //PROBLEM WITH CAPTURE
            if let msgController = self.presentingViewController as? MsgListViewController {
                //store user info upon login
                
                msgController.getUserInfo(password: password)
            }
            else {
                print("msgController not successfully captured")
            }
            //stop the loading wheel
            self.loadingWheel.stopAnimating()
            self.loadingWheel.isHidden = true
            //reenable the sign in button
            self.signInButton.isEnabled = true
            //transition into the app
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        //brings keyboard down when background is pressed
        self.view.endEditing(true)
    }
    
   
    
    var firstTimeLogin = false
    
    override func viewDidLoad() {
        //set text field delegates and hide nav bar for better appearance
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        

        
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingWheel.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //Raises view to accomidate the presence of the keyboard
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let keyboardOffset: CGPoint = CGPoint(x: 0, y: 200)
loginScrollView.setContentOffset(keyboardOffset, animated: true)    }
    
    //Lowers view after keyboard exits
    func textFieldDidEndEditing(_ textField: UITextField) {
        let keyboardOffset: CGPoint = CGPoint(x: 0, y: 0)
        loginScrollView.setContentOffset(keyboardOffset, animated: true)
    }
    
    //enables the return key as a function (lowering keyboard in this case)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
        
    }
    
    @IBAction func unwindToLogIn(unwindSegue: UIStoryboardSegue) {
        navigationController?.navigationBar.isHidden = true
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

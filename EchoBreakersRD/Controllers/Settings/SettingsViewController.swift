//
//  SettingsViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/18/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit
import Firebase
class SettingsViewController: UIViewController {
   
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
    }
    @IBAction func rememberMeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            rememberMe = true
            
        }
        else {
            rememberMe = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        //clear current user data
        currentUser.email = "nil"
        currentUser.ID = "nil"
        currentUser.name = "nil"
        currentUser.profilePic = #imageLiteral(resourceName: "GeneralProfilePic")
        //segue to login
        performSegue(withIdentifier: "toLoginFromSettings", sender: self)
        //display Message Queue screen
        tabBarController?.selectedIndex = 0
        
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

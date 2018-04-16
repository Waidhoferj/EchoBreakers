//
//  ProfileViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/2/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var levelNumberLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.layer.cornerRadius = 100
        profilePhoto.layer.masksToBounds = true
        profilePhoto.image = #imageLiteral(resourceName: "Profile Pic")
        nameLabel.text = "John Waidhofer"
        levelNumberLabel.text = "19"
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

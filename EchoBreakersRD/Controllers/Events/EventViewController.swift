//
//  EventViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/3/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit
//FIRST LAST NAME SPLIT IS NO LONGER FUNCTIONAL
class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableOutlineView: UIView!
    @IBOutlet weak var peopleTableView: UITableView!
    
   var participants: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.estimatedRowHeight = 100
        tableOutlineView.layer.cornerRadius = 30
        tableOutlineView.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") as! EventTableViewCell
        cell.profilePhoto.layer.cornerRadius = 40
        cell.profilePhoto.layer.masksToBounds = true
//        cell.firstNameLabel.text = participants[indexPath.row].firstName
//        cell.lastNameLabel.text = participants[indexPath.row].lastName
        cell.profilePhoto.image = participants[indexPath.row].profilePic
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPrompt", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
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

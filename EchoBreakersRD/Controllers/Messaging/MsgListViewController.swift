//
//  MsgListViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/1/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit
import Firebase
class MsgListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var msgTableView: UITableView!
    @IBOutlet weak var newMessageButton: UIButton!
    @IBOutlet weak var plusBackgroundCircle: UIView!
    
    @IBAction func newMessageButtonPressed(_ sender: UIButton) {
        newMessageButton.backgroundColor = UIColor.white
        newMessageButton.alpha = 0.5
    }
    @IBAction func newMessageButtonClicked(_ sender: UIButton) {
        newMessageButton.backgroundColor = UIColor.clear
        performSegue(withIdentifier: "toSearch", sender: self)
        
        
    }
    @IBAction func newMessageButtonTouchCancel(_ sender: UIButton) {
        newMessageButton.backgroundColor = UIColor.clear
    }
    @IBAction func newMessageButtonDraggedOut(_ sender: UIButton) {
        newMessageButton.backgroundColor = UIColor.clear
    }
    
    //Variables
    var conversationSelected = Int()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    var conversations: [Conversation] = [Conversation(ID: "testConversation", recipient: "Alistar Smith", storedMessages: nil, profilePhoto: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //maybe make user log in before prompts are called for in the future
        getPrompts()
        
        
        msgTableView.estimatedRowHeight = 85
        plusBackgroundCircle.layer.cornerRadius = 0.5 * plusBackgroundCircle.frame.height

        checkIfUserIsLoggedIn()
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCellID") as! ConversationCell
        
        cell.pictureView.image = conversations[indexPath.row].recipientProfilePhoto
        cell.nameLabel.text = conversations[indexPath.row].recipientName
        cell.previewLabel.text = conversations[indexPath.row].previewText
        cell.selectedBackgroundView?.layer.cornerRadius = 37
        
        cell.selectionStyle = .blue
        cell.cellViewBackground.layer.cornerRadius = 40
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)!
        conversationSelected = indexPath.row
        performSegue(withIdentifier: "toMessaging", sender: self)
        selectedCell.isSelected = false
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func fetchConversations() {
        //connect to firebase and get the previous conversations
        
        //append the conversations to the conversation array
    }
    
    func checkIfUserIsLoggedIn() {
//
        if rememberMe {
            guard let userToLogin = storedUser else {return}
            Auth.auth().signIn(withEmail: userToLogin.email, password: "dummy password") { (user, issue) in
                if issue != nil {
                    Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.logout), userInfo: nil, repeats: false)
                }
                
            }
        }
        else if  Auth.auth().currentUser?.uid == nil {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(logout), userInfo: nil, repeats: false)
            
        }
    }
    
    func getUserInfo(password: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { print("uid not unwrapped correctly")
            return
        }
        DBRef.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                //download user info
                
                currentUser.email = dictionary["email"] as! String
                currentUser.name = dictionary["name"] as! String
                currentUser.ID = uid
                guard let userPicURL = URL(string: (dictionary["profileImageURL"] as! String)) else {
                    print("URL Was Not Successfully downcast"); return
                }
                let photoGetter = URLSession.shared.dataTask(with: userPicURL, completionHandler: { (myData, myResponse, err) in
                    if err != nil {
                        print(err!)
                        return
                    }
                    
                    currentUser.profilePic = UIImage(data: myData!)!
                })
                
                photoGetter.resume()
            }

        }, withCancel: nil)
        
        if rememberMe {
            storedUser = currentUser
            
            storedUser?.password = password
        }
    }
    
    @objc func logout() {
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
        
        performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    func getPrompts() {
        DBRef.child("Prompts").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String] else {print("could not unwrap prompt dictionary"); return}
            self.appDelegate.globalPromptList = dictionary
            
        }, withCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessaging" {
            guard let chatVC = segue.destination as? ChatViewController else {print("ID transfer failed"); return}
        chatVC.chatID = conversations[conversationSelected].ID
            if let texts = conversations[conversationSelected].storedMessages {
            chatVC.messages = texts
            }
            chatVC.recipientProfileImage = conversations[conversationSelected].recipientProfilePhoto
            chatVC.navigationItem.title = conversations[conversationSelected].recipientName
            chatVC.promptsAccessed = conversations[conversationSelected].promptsAccessed
        }
    }
    @IBAction func unwindToMsgList(unwindSegue: UIStoryboardSegue) {            
        
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

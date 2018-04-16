//
//  SearchViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/19/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchImage: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBAction func backgroundButtonPressed(_ sender: Any) {
        //returns to the recent messages list when the background is pressed
        dismiss(animated: true) {
            // clear observers and take user out of queue
            DBRef.child("ConversationSearchQueue").child((Auth.auth().currentUser?.uid)!).removeAllObservers()
            DBRef.child("ConversationSearchQueue").child((Auth.auth().currentUser?.uid)!).removeValue()
            
            
        }
    }
    
    
    @IBAction func searchButtonTouchedDown(_ sender: UIButton) {
        searchImage.alpha = 0.5
    }
    @IBAction func searchButtonDragExit(_ sender: Any) {
        searchImage.alpha = 1
    }
    
    
    @IBAction func searchPressed(_ sender: UIButton) {
        //reset the button to not highlighted
        searchImage.alpha = 1
        beginLoadAnimation()
        //matches user with another person
        findPartner()
    }
    //Reference to UI objects
    @IBOutlet weak var userProfileImage: UIImageView!
    
    //Variables
    var partnerIdentifier: String?
    var chatID = String()
    let shapeLayer = CAShapeLayer()
    var createdChat: Conversation?
    var statusText: String = "Click search to find new match" {
        didSet {
            statusTextView.text = statusText
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        shapeLayer.isHidden = true
        createLoadingIndicator()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func findPartner()  {
        //Connect user with random person looking for a conversation
        //Safely unwrap the ID of the current user
        guard let uid = Auth.auth().currentUser?.uid else { print("failed to unwrap uid"); return}
        //Create reference to the queue of people looking for conversations. People are added to this queue if there is no one in the queue already. If there are people in the queue currently, the conversation seeker notifies the person in the queue, who is then removed and coupled into a conversation
        let queueRef = DBRef.child("ConversationSearchQueue")
        let userRef = queueRef.child(uid)
        queueRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //check if anyone is in the queue by attempting to unwrap a value
            guard let dictionary = snapshot.value as? [String: AnyObject?]
                else {
                    //If there is no one in the queue, add my personal user ID to the empty group and wait for another participant
                    let values = ["coupledWithID": "false"]
                    userRef.updateChildValues(values) { (error, reference) in
                        if error != nil {
                            print(error!)
                        }
                        
                    }
                    
                    self.statusText = "waiting in queue..."
                    //add observer to start chat if there is a connection
                    
                    userRef.observe(.childChanged, with: { (snapshot) in
                        self.statusText += "found user, creating chat"
                        
                        
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            //remove self from queue
                            userRef.removeValue()
                            guard let dictionaryInfo = snapshot.value as? [String: AnyObject?] else {print("problem unwrapping dictionary"); return}
                            
                            guard let chatMateName = dictionaryInfo["syncedUser"] as? String, let createdGroupID = dictionaryInfo["coupledWithID"] as? String else {print("problem with unwrapping  queue-side info"); return}
                            
                            
                            self.partnerIdentifier = chatMateName
                            self.startChat(withID: createdGroupID )
                        }, withCancel: nil)
                       
                    }, withCancel: nil)
                    return
            }
            //If there is someone in the queue, obtain their user ID
            //Check that it is not yourself
            guard (dictionary.first?.key)! != uid else{print("user already in queue"); return}
            //get the person's ID
            let partnerUid = (dictionary.first?.key)!
            
            queueRef.child(partnerUid).observeSingleEvent(of: .value, with: { (snapshot) in
                //check to see if they have already synced with another user
                let boolDictionary = snapshot.value as! [String: String]
                let waitingStatus = boolDictionary.first?.value
                if waitingStatus == "false" {
                    self.statusText = "found user, creating chat..."
                    
                    //Initialize conversation on database
                    let groupID = DBRef.child("Conversations").childByAutoId()
                    //Store ID for conversation locally
                    self.chatID = groupID.key
                    print("this is the group ID key:", self.chatID)
                    
                    //give the waiting user the conversation ID
                    self.partnerIdentifier = partnerUid
                    let values = ["coupledWithID": self.chatID, "syncedUser": uid];
                    
                    queueRef.child(partnerUid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                        }
                        //When the other user is notified about the ID, sign self up to chat
                        self.startChat(withID: self.chatID)
                    })
                    
                }
                else {
                    print("The user who you were matched with was taken by another person before we could link you. Please press search again to search for another user")
                }
            }, withCancel: nil)
            
            
            
            

        }, withCancel: nil)
        
        
    }
    
    func startChat(withID conversationID: String) {

        
       
        
        //Write in self as a member of the chat
        let values = ["member" : (Auth.auth().currentUser?.uid)!]
        DBRef.child("Conversations").child(conversationID).updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
        
        //Add the coversation ID into user data
//        let todaysDate: String = {
//            let myDate = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd.MM.yyy"
//            let dateString = formatter.string(from: myDate)
//            return dateString
//        }()
        let conversationValues = ["chat started on (Date)" : conversationID] //possibly better date format later
        DBRef.child("Users").child((Auth.auth().currentUser?.uid)!).child("Conversations").updateChildValues(conversationValues) { (error, ref) in
            if error != nil {
                print(error!)
            }
        }
        
        //Create new chat on device
        //Get name of recipient from database TOO LOW PRIVACY FOR FINAL. POSSIBLE ID ISSUE HERE.
        var recipientName: String?
        var profilePicture: UIImage?
         if let chatMateID = partnerIdentifier{
        DBRef.child("Users").child(chatMateID).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject?] {
                //capture name value
                recipientName = dictionary["name"] as? String
                //get profile image link
                let profilePicLink = dictionary["profileImageURL"] as? String
                if profilePicLink != "nil" {
                    //get the profile image UNSAFE CONFIGURATION
                    let url = URL(string: profilePicLink!)!
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        //assign data to local profile pic variable
                        profilePicture = UIImage(data: data!)
                        //Create the new conversation
                        let newConversation = Conversation(ID: conversationID, recipient: recipientName!, storedMessages: nil, profilePhoto: profilePicture!)
                        self.createdChat = newConversation
                        
                        
                        
                        //Send the conversation to the MsgListVC
                        
                        self.performSegue(withIdentifier: "closeSearchScreen", sender: self)
                    }).resume()
                }
                
            }
            else {
                print("couldn't unwrap the username of the recipient from dictionary")
            }
        }
    }
         else {
            print("couldn't unwrap the username of the recipient from local source")
        }
        
        
    }
    
    func createLoadingIndicator() {
     
    let circleCenter = searchImage.center
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: 100, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = kCALineCapRound
        view.layer.addSublayer(shapeLayer
        )
        


        
    }
    
    func beginLoadAnimation() {
        shapeLayer.isHidden = false
        let loadAnimation = CABasicAnimation(keyPath: "strokeEnd")
        loadAnimation.fromValue = 0
        loadAnimation.toValue = 1
        loadAnimation.duration = 2
        loadAnimation.repeatCount = .infinity
        
//        let loadAnimationTwo = CABasicAnimation(keyPath: "strokeStart")
//        loadAnimationTwo.fromValue = 0
//        loadAnimationTwo.toValue = 1
//        loadAnimationTwo.duration = 4
//        loadAnimationTwo.repeatCount = 5
        
        shapeLayer.add(loadAnimation, forKey: "this")
//        shapeLayer.add(loadAnimationTwo, forKey: "this")
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "closeSearchScreen" {
            guard let newConversation = createdChat, let MSGVC = segue.destination as? MsgListViewController else {
                print("there isn't a new chat to transfer, or the VC could not be found"); return
            }
  
            MSGVC.conversations.append(newConversation)
            //SLOPPY FIX SHOULD BE CALLED FROM MSGVC!!!
            DispatchQueue.main.async {
                MSGVC.msgTableView.reloadData()
            }
            
        }
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

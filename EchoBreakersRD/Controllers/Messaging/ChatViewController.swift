//
//  ChatViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/6/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//
//Reload data does not reload the count and table cells
import UIKit
import Firebase
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    //UI Objects:
    //Table view
    @IBOutlet weak var messageTableView: UITableView!
    //background images
    @IBOutlet weak var recipentBackgroundPic: UIImageView!
    @IBOutlet weak var userBackgroundPic: UIImageView!
    //Typing object references
    @IBOutlet weak var typedTextContainerView: UIView!
    @IBOutlet weak var typedTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var typedTextView: UITextView!
    @IBOutlet weak var typedTextViewHeightConstraint: NSLayoutConstraint!
    //Prompt references
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var promptText: UITextView!
    @IBOutlet weak var promptTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextPromptButtonView: UIView!
    
    
    //Actions:
    
    @IBAction func changePromptButtonPressed(_ sender: UIButton) {
        setPrompt()
        handlePromptChanger()
        //future feature: ask if user is comfortable
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            self.handlePromptChanger()
        }
    }
    @IBAction func promptButtonPressed(_ sender: UIButton) {
        //Modally presents prompt info screen
        performSegue(withIdentifier: "promptInfoSegue", sender: self)
    }
    @IBAction func sendButtonPressed(_ sender: UIButton) {
    //Sends data to server and adds text to chat
    sendText()
    typedTextView.text = ""
        
    }
    
    //Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var prompts = [String]()
    var chatID: String?
    var conversationNumber: Int?
    var promptsAccessed: [Int] = []
    var recipientProfileImage = #imageLiteral(resourceName: "GeneralProfilePic")
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Layout
        setInitialViewStates()
        
        //attach listener for new messages
        receiveNewMessages()
        
        //Watch state of keyboard and adapt UI to its presence or absence
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.messageTableView.contentInset = UIEdgeInsets(top: promptView.frame.height + 7, left: 0, bottom: 0, right: 0)
        
        //Layout text view height
        let contentSize = typedTextView.sizeThatFits(CGSize(width: typedTextView.frame.width, height: 1000))
        typedTextViewHeightConstraint.constant = contentSize.height
        
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //take away the general menu bar at the bottom of the screen
        tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            //Animate profile pictures reappearing while moving them into the center of the screen
            self.recipentBackgroundPic.alpha = 0.6
            self.userBackgroundPic.alpha = 0.6
            self.recipentBackgroundPic.transform = CGAffineTransform(translationX: 0, y: 0)
            self.userBackgroundPic.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: nil)
        
        //Start countdown for new prompt
    Timer.scheduledTimer(withTimeInterval: 5, repeats: false) {_ in
            self.handlePromptChanger()
        }
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //As of now, there is only one section, but we could add separate sections to split up data if there is a need for categorization
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //The number of cells equals the number of values in the messages array
        
            return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //variable made from prototype cell in table
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! TextMessageCell
        cell.messageText.text = messages[indexPath.row].text
        //Calculation for size of message bubble/text
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messages[indexPath.row].text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        //Formats messages based on which side they appear and the height sizing specified above
        switch messages[indexPath.row].side {
        case .right:
            cell.messageText.frame = CGRect(x: cell.contentView.frame.width - estimatedFrame.width - 16 - 10 - 2, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.bubbleView.frame = CGRect(x: cell.contentView.frame.width - estimatedFrame.width - 22 - 10, y: 0, width: estimatedFrame.width + 22, height: estimatedFrame.height + 20)
            cell.bubbleView.backgroundColor = UIColor.blue
            cell.messageText.textColor = UIColor.white
            

        case .left:
            cell.messageText.frame = CGRect(x: 10 + 6, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.bubbleView.frame = CGRect(x: 10, y: 0, width: estimatedFrame.width + 22, height: estimatedFrame.height + 20)
            cell.bubbleView.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
            cell.messageText.textColor = .black
            
        }
        //Put cell in table view
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //Provides height of each cell to accomidate the message
        let messageText =  messages[indexPath.row].text
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        return estimatedFrame.height + 30

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Dismisses keyboard when background is selected
        typedTextView.endEditing(true)
    }
    
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        guard let notificationInfo = notification.userInfo
            else { print("notification info was not effectively contained by let storing"); return}
        //Get the size of the keyboard
        if let keyboardFrame = (notificationInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //Determine if keyboard is showing by comparing notification name to "UIKeyboardWillShow"
            let keyboardShowingStatus = notification.name == NSNotification.Name.UIKeyboardWillShow
            //Change the location of the type message box
            typedTextViewBottomConstraint.constant = keyboardShowingStatus ? keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: { (finished) in
                if keyboardShowingStatus {
                    guard self.messages.count >= 1 else {return}
                    //Redistribute the message data to a visible part of the screen
                    let bottomIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    
                    self.messageTableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: true)
                }
            })
        }
        
        
    }
    

    func sendText() {
        //Add timestamp later if you wish
        //let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
        guard let text = typedTextView.text else {print("no text avaliable to send: textbox is empty"); return}
        let ID = (Auth.auth().currentUser?.uid)!
        let textValues = ["text": text, "from": ID, "timestamp": Date.timeIntervalSinceReferenceDate] as [String : Any]
        DBRef.child("Messages").child(self.chatID!).childByAutoId().updateChildValues(textValues) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            //make it a single call observe
//           let sentMessage = Message(text: text, from: ID)
//            self.messages.append(sentMessage)
//            DispatchQueue.main.async {
//
//                let path = IndexPath(row: self.messages.count - 1, section: 0)
//                self.messageTableView.beginUpdates()
//                self.messageTableView.insertRows(at: [path], with: .fade)
//                self.messageTableView.endUpdates()
//                self.messageTableView.scrollToRow(at: path, at: .bottom, animated: true)
//
//            }
            
            
                    }
        
    }
    
    func setInitialViewStates() {
        
        //Localize prompts
        prompts = appDelegate.globalPromptList
        //Setup prompt
        //setPrompt()
        
        //Set up and hide change prompt button
        nextPromptButtonView.layer.cornerRadius = nextPromptButtonView.frame.width/2
        nextPromptButtonView.clipsToBounds = true
        nextPromptButtonView.alpha = 0
       
        //Implement the cornerRadius and the shadow settings
        typedTextContainerView.layer.shadowOpacity = 0.2
        typedTextContainerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        promptView.layer.shadowOpacity = 0.5
        promptView.layer.shadowOffset = CGSize(width: 0, height: 5)
        promptView.layer.cornerRadius = 20
        //Position background pictures and make them invisible
        recipentBackgroundPic.alpha = 0.0
        userBackgroundPic.alpha = 0.0
        recipentBackgroundPic.transform = CGAffineTransform(translationX: 0, y: 500)
        userBackgroundPic.transform = CGAffineTransform(translationX: 0, y: -500)
        //Set background pictures' cornerRadius and put in the user profile pictures (LATER THE PICTURES WILL HAVE TO BE SET AS A PARAMETER OR OUTSIDE THIS FUNCTION)
        recipentBackgroundPic.layer.cornerRadius = 112.5
        recipentBackgroundPic.clipsToBounds = true
        recipentBackgroundPic.alpha = 0.5
        userBackgroundPic.layer.cornerRadius = 112.5
        userBackgroundPic.clipsToBounds = true
        userBackgroundPic.alpha = 0.5
        recipentBackgroundPic.image = recipientProfileImage
        //THIS HAS TO BE PULLED FROM THE CURRENT USER DATA INSTEAD OF A STATIC PHOTO
        userBackgroundPic.image = currentUser.profilePic
        
        typedTextView.delegate = self
    }
    
    func receiveNewMessages(){
        guard let fetchedChatID = chatID else { print("there is no chatID"); return}
        var isFirstLoad = true
        DBRef.child("Messages").child(fetchedChatID).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
       

                let text = dictionary["text"] as! String
                let senderID = dictionary["from"] as! String
                let time = dictionary["timestamp"] as! Double
                let newMessage = Message(text: text, from: senderID, timeSent: time)
                self.messages.append(newMessage)
                if isFirstLoad{
                DispatchQueue.main.async {
                    self.messages.sort(by: { (m1, m2) -> Bool in
                        return m1.timestamp < m2.timestamp
                    })
                    self.messageTableView.reloadData()
                    
                    
                    let bottomIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    
                    self.messageTableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: true)
                    isFirstLoad = false
                    
                }
                }
                else {
                    DispatchQueue.main.async {
                        
                                            let path = IndexPath(row: self.messages.count - 1, section: 0)
                                                            self.messageTableView.beginUpdates()
                                                            self.messageTableView.insertRows(at: [path], with: .fade)
                                                            self.messageTableView.endUpdates()
                                                            self.messageTableView.scrollToRow(at: path, at: .bottom, animated: true)
                        
                        let bottomIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.messageTableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: true)
                        
                    }
                }
                
            }
        }, withCancel: nil)

        
    }
    
    func setPrompt() {
        
////        //Size prompt to fit text
////        //The prompts index could recalculate and cause problems, be aware if there is a formatting issue
//        guard prompts.count >= 1 else {print("there are no prompts in the local holding variable"); return}
//        var newPromptReference: [Int]
//        for i in 1...(prompts.count - 1) {
//            newPromptReference.append(i)
//        }
//        newPromptReference.filter { (currentNumber) -> Bool in
//
//        }
//        //MAKE THIS MAP LATER
//        let promptIndex = 1
//        let size = CGSize(width: view.frame.width - 30, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//        let estimatedFrame = NSString(string: prompts[promptIndex]).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)], context: nil)
//
//        promptTextHeightConstraint.constant = estimatedFrame.height + 15
//
//        //Set text for prompt
//        promptText.text = prompts[promptIndex]
    }
    
    func handlePromptChanger() {
        //flip the two funcitons. You might want to use something other than an if statement. Something triggered by the end of the timer
        
        
        if nextPromptButtonView.alpha == 0 {
            promptTrailingConstraint.constant = nextPromptButtonView.frame.width + 10
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.nextPromptButtonView.alpha = 1
            })
            
           
        }
        else {
            promptTrailingConstraint.constant = 10
            UIView.animate(withDuration: 1.0, animations: {
                
                self.view.layoutIfNeeded()
                self.nextPromptButtonView.alpha = 0
            })
        }
    }

    
    @IBAction func unwindToChat(unwindSegue: UIStoryboardSegue) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let MSGVC = segue.destination as? MsgListViewController {
            guard let numRef = conversationNumber else {print("found nil convo number"); return}
            MSGVC.conversations[numRef].promptsAccessed = promptsAccessed
            
        }
        else {
            print("prompts used transfer failed"); return
        }
        
        
        
        //invalidate prompt timer here in the future
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


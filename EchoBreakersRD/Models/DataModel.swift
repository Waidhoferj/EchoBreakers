//
//  DataModel.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 11/22/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import Foundation
import UIKit
import Firebase
var rememberMe = true {
    didSet {
        if rememberMe == false {
            storedUser = nil
        }
    }
}

var storedUser: User?
let DBRef = Database.database().reference()
var currentUser: User = User(name: "filler", ID: "filler", email: "filler", profilePic: nil)


class Question {
    var questionText: String
    var answers: [String]
    var backgroundImage: UIImage
    
    
    init(question: String, answers: [String], image: UIImage) {
        questionText = question
        self.answers = answers
        backgroundImage = image
        
    }
}

// conversation model
class Conversation {
    var ID: String
    var recipientName: String
    var previewText: String?
    var storedMessages: [Message]?
    var recipientProfilePhoto: UIImage
    var promptsAccessed: [Int]
    
    init(ID: String, recipient: String, storedMessages: [Message]?, profilePhoto: UIImage?) {
        self.ID = ID
        self.recipientName = recipient
        if let messages = self.storedMessages {
        self.storedMessages = messages
            self.previewText = self.storedMessages?.last?.text
            
        }
        else {
            self.storedMessages = nil
        }
        
        if let photo = profilePhoto {
            
            self.recipientProfilePhoto = photo
        }
        else {
            self.recipientProfilePhoto = #imageLiteral(resourceName: "GeneralProfilePic")
            }
        self.promptsAccessed = [Int(arc4random_uniform(5))]
    }
}
// user model
class User {
    var name: String
    var ID: String
    var email: String
    var profilePic: UIImage
    var password: String?
    init(name: String, ID: String, email: String, profilePic: UIImage?) {
        self.name = name
        self.ID = ID
        self.email = email
        if let photo = profilePic {
            self.profilePic = photo
        }
        else {
            self.profilePic = #imageLiteral(resourceName: "GeneralProfilePic")
        }
        password = nil
    }
}



// prompt model



// Cell type enum

enum BubbleType {
    case right, left
}

// Message class
class Message {
    var text: String
    var from: String
    var side: BubbleType
    var timestamp: Double
    
    init(text: String, from: String, timeSent: Double) {
        self.text = text
        self.from = from
        self.timestamp = timeSent
        
        if from == Auth.auth().currentUser?.uid {
            self.side = .right
        }
        else {
            self.side = .left
        }
        
    }
}

class Event {
    var date: Date
    var title: String
    var participants: [String]
    var image: UIImage
    
    init(date: Date, title: String, participants: [String], image: UIImage?) {
        self.date = date
        self.title = title
        self.participants = participants
        if let providedImage = image {
            self.image = providedImage
        }
        else {
            //put in a placeholder image
            self.image = #imageLiteral(resourceName: "waves")
        }
    }
}




//
//  TutorialViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 11/22/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.


import UIKit

class TutorialViewController: UIViewController {
    //Variables
    //background images for the tutorial. These will be stored in app becasue the tutorial is static.
    var images: [UIImage] = [#imageLiteral(resourceName: "waves"), #imageLiteral(resourceName: "pexels-photo-681381")]
    //text for each page of the tutorial
    var messages: [String] = ["Hey there, here is a quick tutorial to help you get up and running. Swipe left for the next bit <-. If you want to return to the previous screen, swipe right ->", "Okay cool beans, let me tell you a bit about EchoBreakers. We are a community devoted to building friendships with those who think differently. The point of this app is to expand our understanding of the world and to keep ourselves away from a dangerous one-track mindset", "Before we go any further, you need to know about our policy. First and foremost, we care that people are respectful when they are discussing contentious issues. Secondly we would appreciate if you went into each conversation with an open mind, despite what preconceived notions you may have about the other person. Thirdly, no trolling, cyberbullying, or anything of the like. This community is based on respectful argumentation. Stick to proving the facts.", "By going past this point, you agree to these terms and conditions", "great to have you on board! Here's how to use the app: (include more slides later with instructions)"]
    //Indices for the text and pictures. Separated because the number of each may differ
    var imageIndex = 0
    var messageIndex = 0
    //Standard background color stored for recovery from the white shift transition
    let blueBackgroundColor: UIColor = UIColor(displayP3Red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    //References to UI objects
    @IBOutlet weak var InstructionText: UILabel!
    @IBOutlet weak var backgroundTintView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var unwindContainerView: UIView!
    
    //Actions
    @IBAction func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            //Turn the background white which makes the text and image invisible
            self.backgroundTintView.backgroundColor = .white
            self.backgroundTintView.alpha = 1.0
            
        }, completion: {success in
            //swap in the next background image
            if self.imageIndex <= self.images.count - 1 {
            self.backgroundImageView.image = self.images[self.imageIndex]
                self.imageIndex += 1
            }
            else {
                self.imageIndex = 0
            }
            //swap in the new text
            if self.messageIndex <= self.messages.count - 2 {
                    self.messageIndex += 1
                    self.InstructionText.text = self.messages[self.messageIndex]
                if self.messageIndex == self.messages.count - 1 {
                        self.unwindContainerView.isHidden = false
                }
                
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                //Make the screen visible once more by returning the background tint to blue
                self.backgroundTintView.backgroundColor = self.blueBackgroundColor
                self.backgroundTintView.alpha = 0.65}
            )
        })
    }
    
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        //the same code as swipedLeft with slight alterations to change direction of effect
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.backgroundTintView.backgroundColor = .white
            self.backgroundTintView.alpha = 1.0
            
        }, completion: {success in
            if self.imageIndex != 0 {
                self.imageIndex -= 1
                self.backgroundImageView.image = self.images[self.imageIndex]
                
            }
            else {
                self.imageIndex = 0
            }
            if self.messageIndex != 0 {
                    self.messageIndex -= 1
                    self.InstructionText.text = self.messages[self.messageIndex]
                if self.messageIndex == self.messages.count - 2 {
                    self.unwindContainerView.isHidden = true
                }
                
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundTintView.backgroundColor = self.blueBackgroundColor
                self.backgroundTintView.alpha = 0.65}
            )
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set corner radius of the Sign In button and ensure that it is hidden at the start of the tutorial
        unwindContainerView.clipsToBounds = true
        unwindContainerView.layer.cornerRadius = 64
        unwindContainerView.isHidden = true
        
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

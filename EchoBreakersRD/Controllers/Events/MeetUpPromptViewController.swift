//
//  MeetUpPromptViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/16/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class MeetUpPromptViewController: UIViewController {
    @IBOutlet weak var promptViewXCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promptText: UITextView!
    @IBOutlet weak var promptView: UIVisualEffectView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func transitionButtonPressed(_ sender: UIButton) {
        transitionToNextQuestion()
    }
    var prompts: [String] = ["Should gun clip sizes be reduced with federal mandates?", "Who should be the next president? Present one potiential candidate at a time and analyze thier strengths and weaknesses. What stances would they embrace?", "You could put endless prompts in here", "But I do need to create a prompt datastructure in order to store the data points in the more info screen"]
    var promptIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePrompt()
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updatePrompt() {
        //Get new prompt size based on text
        let size = CGSize(width: promptText.frame.width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: prompts[promptIndex]).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)], context: nil)
        //Set height according to calculated size
        promptTextHeightConstraint.constant = estimatedFrame.height + 50
        //put text in the textView
        promptText.text = prompts[promptIndex]
        //adjust the index for the next question
        if promptIndex == prompts.count - 1{
            promptIndex = 0
        }
        else {
            promptIndex += 1
        }
        
    }
    
    
    func prepareSnapshot() -> UIView? {
        let snapshotView = promptView.snapshotView(afterScreenUpdates: false)
        self.view.addSubview(snapshotView!)
        snapshotView?.frame = promptView.frame
        return snapshotView
    }
    
    func transitionToNextQuestion() {
        if let snapshot = prepareSnapshot() {
            let currentSnapshotFrame = snapshot.frame
            
            updatePrompt()
            //place the new prompt at its starting position below the screen
            promptViewCenterYConstraint.constant = self.view.frame.height + promptView.frame.height
            view.layoutIfNeeded()
            //sets the new prompt end location: center of screen
            promptViewCenterYConstraint.constant = 0
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                //move old prompt up and off the screen
                snapshot.frame = CGRect(x: currentSnapshotFrame.origin.x, y: -currentSnapshotFrame.height - 5, width: currentSnapshotFrame.width, height: currentSnapshotFrame.height)
                //initiate the new prompt constraint. Move up and to center of screen
                self.view.layoutIfNeeded()
                
                
            }, completion: { (success) in
                snapshot.removeFromSuperview()
            })
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

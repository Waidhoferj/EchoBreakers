//
//  SurveyViewController.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 11/26/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {

    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextBackgroundImageView: UIImageView!
    @IBOutlet weak var nextQuestionLabel: UILabel!
    
    @IBOutlet var nextButtonCollection: [UIButton]!
    
    @IBOutlet weak var nextViewXCenterConstraint: NSLayoutConstraint!
    
    @IBOutlet var ButtonCollection: [UIButton]!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBAction func nextQuestionRequested(_ sender: UISwipeGestureRecognizer) {
        slideIndex += 1
        questionTransition()
        
        
    }
    
    var slideIndex: Int = 0
    
    var questions: [Question] = [Question(question: "Should Police Wear Body Cams", answers: ["Yes", "No", "Undecided", "Other"], image: #imageLiteral(resourceName: "policePhoto")), Question(question: "Which party do you identify with the most", answers: ["Democrat", "Republican", "Independant", "Other"], image: #imageLiteral(resourceName: "pexels-photo-129112"))  ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: 400, y: 0))
        loadUI()
        
        
        
    
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadUI() {
        questionLabel.text = questions[slideIndex].questionText
        backgroundImageView.image = questions[slideIndex].backgroundImage
        for i in 0...3 {
            ButtonCollection[i].titleLabel?.text = questions[slideIndex].answers[i]
        }
    }
    
    func questionTransition() {
        nextQuestionLabel.text = questions[slideIndex].questionText
        nextBackgroundImageView.image = questions[slideIndex].backgroundImage
//        for i in 0...3 {
//            nextButtonCollection[i].titleLabel?.text = questions[slideIndex].answers[i]
//        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.nextView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0).concatenating(CGAffineTransform(translationX: 0, y: 0))
            }, completion: {success in
                self.loadUI()
                self.nextView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: 400, y: 0))
                print("Animation Successful")
        })
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

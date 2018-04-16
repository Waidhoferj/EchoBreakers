//
//  MessageTextView.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/20/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isScrollEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeight), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    @objc func updateHeight() {
        //Adaptive animation
        
        
        var newFrame = frame
        
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: fixedWidth, height: newSize.height)
        
        
        let topMargin: CGFloat = 16
        let textLineHeight: CGFloat = 21.5
        let maxNonScrollLines: CGFloat = 6
        if newFrame.height <= (topMargin + (textLineHeight * maxNonScrollLines)) {
        isScrollEnabled = false
        self.frame = newFrame
        }
        else {
            isScrollEnabled = true
            flashScrollIndicators()
            
        }
        
        // suggest searching stackoverflow for "uiview animatewithduration" for frame-based animation
        // or "animate change in intrinisic size" to learn about a more elgant solution :)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

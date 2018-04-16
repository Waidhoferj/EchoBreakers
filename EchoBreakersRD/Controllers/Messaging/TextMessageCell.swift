//
//  TextMessageCell.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/13/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class TextMessageCell: UITableViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 15
        bubbleView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    func rightSide() {
        let sideConstraintForView = NSLayoutConstraint(item: bubbleView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 10)
        let topConstraintForView = NSLayoutConstraint(item: bubbleView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let sideConstraintForText = NSLayoutConstraint(item: messageText, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 10)
        let topConstraintForText = NSLayoutConstraint(item: messageText, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        
        bubbleView.addConstraint(sideConstraintForView)
        bubbleView.addConstraint(topConstraintForView)
        messageText.addConstraint(sideConstraintForText)
        messageText.addConstraint(topConstraintForText)

    }
    
}

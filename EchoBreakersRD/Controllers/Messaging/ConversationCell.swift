//
//  ConversationCell.swift
//  EchoBreakersRD
//
//  Created by John Waidhofer on 12/1/17.
//  Copyright © 2017 John Waidhofer. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    @IBOutlet weak var pictureView: UIImageView! {
        didSet {
            pictureView.layer.cornerRadius = 0.5 * pictureView.frame.height
            pictureView.clipsToBounds = true
            
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var cellViewBackground: UIView!
    @IBOutlet weak var pictureBorder: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        pictureBorder.layer.cornerRadius = 0.5 * pictureBorder.frame.height
        cellViewBackground.layer.shadowOpacity = 0.4
        cellViewBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

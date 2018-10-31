//
//  FeedTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 17/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var dayTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.setShadow(radius: 6)

        self.profileImageView.layer.cornerRadius = 35
        self.profileImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

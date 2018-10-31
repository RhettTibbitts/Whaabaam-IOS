//
//  RecieverTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish on 30/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class RecieverTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.setShadow(radius: 4)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

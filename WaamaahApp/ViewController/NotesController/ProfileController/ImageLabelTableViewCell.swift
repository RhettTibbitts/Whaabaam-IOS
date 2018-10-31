//
//  ImageLabelTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 27/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ImageLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var rightConstant: NSLayoutConstraint!
    @IBOutlet weak var xConstant: NSLayoutConstraint!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var viewResumeBtn: UIButton!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var labelRightConstant: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

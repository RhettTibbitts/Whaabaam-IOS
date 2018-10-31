//
//  TextFieldTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    //outlet
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var inputTextField: TLFloatLabelTextField!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgotBtnWidthConstant: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

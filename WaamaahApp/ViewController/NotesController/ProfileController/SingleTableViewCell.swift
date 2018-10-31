//
//  SingleTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 24/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class SingleTableViewCell: UITableViewCell {

    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var inputTextField: TLFloatLabelTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.inputTextField.placeHolderColor = UIColor.lightGray
        self.inputTextField.titleTextColour = UIColor.lightGray
        self.inputTextField.titleActiveTextColour = UIColor.lightGray
        self.inputTextField.bottomLineView.isHidden = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

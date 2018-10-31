//
//  DoubleTextFieldTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 24/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class DoubleTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var secondSelectionBtn: UIButton!
    @IBOutlet weak var firstSelectionBtn: UIButton!
    @IBOutlet weak var notificationBTn: UIButton!
    @IBOutlet weak var secondSeperatorLabel: UILabel!
    @IBOutlet weak var firstSepaaratorLabel: UILabel!
    @IBOutlet weak var secondTextField: TLFloatLabelTextField!
    @IBOutlet weak var firstTextField: TLFloatLabelTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.firstTextField.placeHolderColor = UIColor.lightGray
        self.firstTextField.titleTextColour = UIColor.lightGray
        self.firstTextField.titleActiveTextColour = UIColor.lightGray
        self.firstTextField.bottomLineView.isHidden = true;
        self.secondTextField.placeHolderColor = UIColor.lightGray
        self.secondTextField.titleTextColour = UIColor.lightGray
        self.secondTextField.titleActiveTextColour = UIColor.lightGray
        self.secondTextField.bottomLineView.isHidden = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

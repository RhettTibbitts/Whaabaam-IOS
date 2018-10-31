//
//  TwoTextfieldTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 16/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class TwoTextfieldTableViewCell: UITableViewCell {

    @IBOutlet weak var secondTextField: TLFloatLabelTextField!
    @IBOutlet weak var firstTextfield: TLFloatLabelTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

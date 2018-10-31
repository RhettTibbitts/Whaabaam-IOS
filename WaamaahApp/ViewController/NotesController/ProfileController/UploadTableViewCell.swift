//
//  UploadTableViewCell.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 25/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class UploadTableViewCell: UITableViewCell {

    @IBOutlet weak var icloudBtn: UIButton!
    @IBOutlet weak var driveUploadBtn: UIButton!
    @IBOutlet weak var dropboxUploadBtn: UIButton!
    @IBOutlet weak var deleteResumeBtn: UIButton!
    @IBOutlet weak var fileUploadBtn: UIButton!
    @IBOutlet weak var openResumeBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

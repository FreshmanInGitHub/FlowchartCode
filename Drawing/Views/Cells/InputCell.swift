//
//  InputCell.swift
//  Drawing
//
//  Created by Young on 2019/2/19.
//  Copyright © 2019 Young. All rights reserved.
//

import UIKit

class InputCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  TeamPlayerTableViewCell.swift
//  Stat
//
//  Created by William on 7/6/2017.
//  Copyright © 2017 William. All rights reserved.
//

import UIKit

class TeamPlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbNumber: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

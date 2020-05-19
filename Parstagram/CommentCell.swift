//
//  CommentCell.swift
//  Parstagram
//
//  Created by Yanjie Xu on 2020/5/19.
//  Copyright © 2020 Yanjie Xu. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var commentLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

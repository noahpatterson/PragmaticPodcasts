//
//  EpisodeCell.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/27/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet var artworkImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

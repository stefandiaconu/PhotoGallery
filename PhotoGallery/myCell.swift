//
//  myCell.swift
//  PhotoAlbum
//
//  Created by Stefan Diaconu on 25/03/2019.
//  Copyright © 2019 Stefan Diaconu. All rights reserved.
//

import UIKit
import Photos

class myCell: UICollectionViewCell {
    @IBOutlet weak var myImage: UIImageView!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                //This block will be executed whenever the cell’s selection state is set to true (i.e For the selected cell)
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.contentView.tintColor = UIColor.red
            }
            else
            {
                //This block will be executed whenever the cell’s selection state is set to false (i.e For the rest of the cells)
                self.transform = CGAffineTransform.identity
                self.contentView.tintColor = UIColor.yellow
            }
        }
    }
}

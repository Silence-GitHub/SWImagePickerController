//
//  SWImagePickerCell.swift
//  SWImagePickerController
//
//  Created by Kaibo Lu on 16/9/27.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit

class SWImagePickerCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.frame.origin.x = 0
        imageView.frame.origin.y = 0
        imageView.frame.size.width = self.contentView.bounds.size.width
        imageView.frame.size.height = self.contentView.bounds.size.height
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    fileprivate static let selectedImageViewHeight: CGFloat = 23

    lazy var selectImageView: UIImageView = {
        let selectImageView = UIImageView()
        selectImageView.frame.origin.x = self.contentView.bounds.size.width - selectedImageViewHeight - 1
        selectImageView.frame.origin.y = self.contentView.bounds.size.height - selectedImageViewHeight - 1
        selectImageView.frame.size.width = selectedImageViewHeight
        selectImageView.frame.size.height = selectedImageViewHeight
        self.contentView.insertSubview(selectImageView, aboveSubview: self.imageView)
        return selectImageView
    }()
    
    lazy var selectLabel: UILabel = {
        let selectLabel = UILabel()
        selectLabel.font = UIFont.systemFont(ofSize: 13)
        selectLabel.textColor = UIColor.white
        selectLabel.textAlignment = .center
        selectLabel.frame = self.selectImageView.frame
        selectLabel.backgroundColor = UIColor(colorLiteralRed: 0.071, green: 0.588, blue: 0.859, alpha: 1)
        selectLabel.layer.cornerRadius = selectLabel.frame.size.width / 2
        selectLabel.layer.masksToBounds = true
        self.contentView.insertSubview(selectLabel, aboveSubview: self.selectImageView)
        return selectLabel
    }()
}

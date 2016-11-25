//
//  SWImagePickerAlbumCell.swift
//  PandaUniversityTeacher
//
//  Created by Kaibo Lu on 16/10/12.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit

class SWImagePickerAlbumCell: UITableViewCell {
    
    static let cellHeight: CGFloat = imageHeight + imageToBottomMargin
    fileprivate static let imageHeight: CGFloat = 100
    fileprivate static let imageToBottomMargin: CGFloat = 3
    
    lazy var previewImageView: UIImageView = {
        let previewImageView = UIImageView()
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        self.contentView.addSubview(previewImageView)
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: previewImageView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .left,
            multiplier: 1,
            constant: 3))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: previewImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: previewImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: SWImagePickerAlbumCell.imageHeight))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: previewImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: SWImagePickerAlbumCell.imageHeight))
        
        return previewImageView
    }()
    
    lazy var albumTitleLabel: UILabel = {
        let albumTitleLabel = UILabel()
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleLabel.font = UIFont.systemFont(ofSize: 15)
//        albumTitleLabel.textColor = UIColor.black
        self.contentView.addSubview(albumTitleLabel)
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: albumTitleLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.previewImageView,
            attribute: .right,
            multiplier: 1,
            constant: 23))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: albumTitleLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self.previewImageView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        
        return albumTitleLabel
    }()
    
    lazy var photosCountLabel: UILabel = {
        let photosCountLabel = UILabel()
        photosCountLabel.translatesAutoresizingMaskIntoConstraints = false
        photosCountLabel.font = UIFont.systemFont(ofSize: 15)
        photosCountLabel.textColor = UIColor.gray
        self.contentView.addSubview(photosCountLabel)
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: photosCountLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.albumTitleLabel,
            attribute: .right,
            multiplier: 1,
            constant: 8))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: photosCountLabel,
            attribute: .right,
            relatedBy: .lessThanOrEqual,
            toItem: self.contentView,
            attribute: .right,
            multiplier: 1,
            constant: -15))
        self.contentView.addConstraint(NSLayoutConstraint(
            item: photosCountLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self.albumTitleLabel,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))
        
        return photosCountLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

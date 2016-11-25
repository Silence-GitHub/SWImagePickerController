//
//  SWImagePickerTitleView.swift
//  SWImagePickerController
//
//  Created by Kaibo Lu on 16/9/27.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit

@objc protocol SWImagePickerTitleViewDelegate {
    func imagePickerTitleViewTapped(_ titleView: SWImagePickerTitleView)
}

class SWImagePickerTitleView: UIView {
    
    weak var delegate: SWImagePickerTitleViewDelegate?
    
    lazy var label: UILabel = {
        let label = UILabel()
//        label.backgroundColor = UIColor.yellowColor()
        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.textColor = UIColor.white
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Arrow_down_black"))
        self.addSubview(imageView)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(titleViewTapped(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func titleViewTapped(_ sender: AnyObject) {
//        print("titleViewTapped:")
        delegate?.imagePickerTitleViewTapped(self)
    }
    
    func layoutTitleView() {
        label.sizeToFit()
        label.frame.origin.x = (self.bounds.size.width - label.bounds.size.width) / 2
        label.frame.origin.y = (self.bounds.size.height - label.bounds.size.height) / 2
        imageView.frame.size.width = 15
        imageView.frame.size.height = 15
        imageView.frame.origin.x = (label.frame).maxX + 3
        imageView.frame.origin.y = (self.bounds.size.height - imageView.frame.size.height) / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

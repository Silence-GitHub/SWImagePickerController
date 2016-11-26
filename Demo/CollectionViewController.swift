//
//  CollectionViewController.swift
//  SWImagePickerController
//
//  Created by Kaibo Lu on 2016/11/25.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

enum CollectionViewControllerSelectImageStyle {
    case PushSingle
    case PushMultiple
    case PresentSingle
    case PresentMultiple
}

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, SWImagePickerControllerDelegate {

    var selectImageType: CollectionViewControllerSelectImageStyle = .PushSingle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch selectImageType {
        case .PushSingle:
            title = "Push Single"
        case .PushMultiple:
            title = "Push Multiple"
        case .PresentSingle:
            title = "Present Single"
        default:
            title = "Present Multiple"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(CollectionViewController.selectButtonClicked(_:)))
    }
    
    @objc private func selectButtonClicked(_ sender: AnyObject) {
        let picker = SWImagePickerController()
        picker.delegate = self
        
        if selectImageType == .PushSingle {
            picker.allowsMultipleSelection = false // or picker.maxSelectionCount = 1
            navigationController?.pushViewController(picker, animated: true)
            
        } else if selectImageType == .PushMultiple {
            picker.maxSelectionCount = 3 // default is 5
            navigationController?.pushViewController(picker, animated: true)
            
        } else if selectImageType == .PresentSingle {
            picker.maxSelectionCount = 1 // or picker.allowsMultipleSelection = false
            let nc = UINavigationController(rootViewController: picker)
            present(nc, animated: true, completion: nil)
            
        } else {
            // Present and select 5 photos at most
            let nc = UINavigationController(rootViewController: picker)
            present(nc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Collection view data source

    var images = [UIImage]()

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let imagePickerCell = cell as? SWImagePickerCell {
            imagePickerCell.imageView.image = images[indexPath.item]
        }
    
        return cell
    }

    // MARK: - SWImagePickerControllerDelegate
    
    func imagePickerController(_ picker: SWImagePickerController, didFinishPickingImageWithInfos infos: [[String : AnyObject]]) {
        
        images.removeAll()
        for dict in infos {
            images.append(dict[SWImagePickerControllerImage] as! UIImage)
            print("Asset local id: \(dict[SWImagePickerControllerAssetLocalIdentifier])")
        }
        collectionView?.reloadData()
    }
}

//
//  SWImagePickerController.swift
//  SWImagePickerController
//
//  Created by Kaibo Lu on 16/9/27.
//  Copyright © 2016年 PandaLearn. All rights reserved.
//

import UIKit
import Photos

let SWImagePickerControllerImage = "Image" // Value is UIImage
let SWImagePickerControllerAssetLocalIdentifier = "AssetLocalIdentifier" // Value is String

@objc protocol SWImagePickerControllerDelegate {
    func imagePickerController(_ picker: SWImagePickerController, didFinishPickingImageWithInfos infos: [[String : AnyObject]])
    @objc optional func imagePickerControllerDidCancel(_ picker: SWImagePickerController)
}

class SWImagePickerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, SWImagePickerTitleViewDelegate {
    
    // MARK: - Properties
    
    weak var delegate: SWImagePickerControllerDelegate?
    var imageTargetSize = UIScreen.main.bounds.size
    
    var allowsMultipleSelection = true {
        didSet {
            if !allowsMultipleSelection {
                if maxSelectionCount != 1 {
                    maxSelectionCount = 1
                }
            } else if maxSelectionCount == 1 {
                maxSelectionCount = 5
            }
        }
    }
    
    var maxSelectionCount = 5 {
        didSet {
            if maxSelectionCount <= 1 {
                if maxSelectionCount != 1 {
                    maxSelectionCount = 1
                }
                
                if allowsMultipleSelection {
                    allowsMultipleSelection = false
                }
            } else if !allowsMultipleSelection {
                allowsMultipleSelection = true
            }
        }
    }
    
    fileprivate var selectedIndexPaths = [IndexPath]() {
        didSet {
            if allowsMultipleSelection {
                confirmButton.setTitle("OK(\(selectedIndexPaths.count))", for: UIControlState())
            }
            navigationItem.rightBarButtonItem!.isEnabled = selectedIndexPaths.count > 0
            let color = selectedIndexPaths.count > 0 ? confirmButton.tintColor : SWImagePickerController.confirmButtonUnenableTitleColor
            confirmButton.setTitleColor(color, for: .normal)
        }
    }
    
    fileprivate static let confirmButtonUnenableTitleColor = UIColor.gray
    fileprivate static let navigationBarButtonTitleFont = UIFont.boldSystemFont(ofSize: 15)
    fileprivate static let navigationBarButtonHeight: CGFloat = 23
    
    fileprivate lazy var confirmButton: UIButton = {
        var frame = CGRect(x: 0, y: 0, width: 25, height: navigationBarButtonHeight)
        var title = "OK"
        if self.allowsMultipleSelection {
            frame.size.width = 50
            title = "OK(0)"
        }
        let confirmButton = UIButton(frame: frame)
        confirmButton.setTitle(title, for: .normal)
        confirmButton.titleLabel?.font = navigationBarButtonTitleFont
        confirmButton.setTitleColor(confirmButtonUnenableTitleColor, for: .normal)
        return confirmButton
    }()
    
    fileprivate var assetCollections = [PHAssetCollection]() {
        didSet {
            navigationTableView.reloadData()
        }
    }
    
    fileprivate var assets = [PHAsset]() {
        willSet {
            if let lastAsset = newValue.last {
                imageManager.startCachingImages(for: [lastAsset], targetSize: cellSize, contentMode: .aspectFill, options: nil)
            }
        }
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate var imageManager = PHCachingImageManager()
    
    fileprivate lazy var titleView: SWImagePickerTitleView = {
        let titleView = SWImagePickerTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width / 3, height: 40))
        titleView.delegate = self
        self.navigationItem.titleView = titleView
        return titleView
    }()
    
    fileprivate var isNavigationRootController: Bool  {
        get {
            return navigationController?.viewControllers.first == self
        }
    }
    
    fileprivate var navigationBarMaxY: CGFloat {
        get {
            if let nc = self.navigationController {
                if isNavigationRootController {
                    // By presenting
                    return UIApplication.shared.statusBarFrame.maxY + nc.navigationBar.frame.maxY
                } else {
                    // By pushing
                    return nc.navigationBar.frame.maxY
                }
            }
            return 0
        }
    }
    
    fileprivate static let album_cell_id = "Album_cell_id"
    
    fileprivate lazy var navigationTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(SWImagePickerAlbumCell.self, forCellReuseIdentifier: SWImagePickerController.album_cell_id)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.scrollsToTop = false
        tableView.tableFooterView = UIView()
        self.view.insertSubview(tableView, aboveSubview: self.collectionView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .top,
            multiplier: 1,
            constant: self.navigationBarMaxY))
        self.view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .bottom,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .left,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: tableView,
            attribute: .right,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .right,
            multiplier: 1,
            constant: 0))
        tableView.transform.ty = -self.view.bounds.size.height
        
        return tableView
    }()
    
    fileprivate static let imageSpace = CGFloat(1)
    fileprivate static let rowCellCount = 4
    
    fileprivate var cellSize: CGSize {
        get {
            let length = (self.view.bounds.size.width - SWImagePickerController.imageSpace * CGFloat(SWImagePickerController.rowCellCount - 1)) / CGFloat(SWImagePickerController.rowCellCount)
            return CGSize(width: length, height: length)
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = imageSpace
        layout.minimumInteritemSpacing = imageSpace / 2
        layout.itemSize = self.cellSize
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(
            item: collectionView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .top,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: collectionView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .bottom,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: collectionView,
            attribute: .left,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .left,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: collectionView,
            attribute: .right,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .right,
            multiplier: 1,
            constant: 0))
        
        return collectionView
    }()
    
    fileprivate var assetCollectionTitleDict: [String : String] {
        get {
            return ["Camera Roll" : "相机胶卷",
                    "Recently Added" : "最近添加",
                    "Favorites" : "个人收藏",
                    "Selfies" : "自拍",
                    "Screenshots" : "屏幕快照"]
        }
    }
    
    // MARK: - View controller life cycle
    
    fileprivate static let imagePickerCellID = "Image_picker_cell_id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.white
        view.backgroundColor = color
        
        // Cancel button
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: SWImagePickerController.navigationBarButtonHeight))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(cancelButton.tintColor, for: .normal)
        cancelButton.titleLabel?.font = SWImagePickerController.navigationBarButtonTitleFont
        cancelButton.addTarget(self, action: #selector(SWImagePickerController.cancelButtonClicked(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        // OK button
        confirmButton.addTarget(self, action: #selector(SWImagePickerController.rightButtonClicked(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        navigationItem.rightBarButtonItem!.isEnabled = false
        
        // Collection view
        collectionView.register(SWImagePickerCell.self, forCellWithReuseIdentifier: SWImagePickerController.imagePickerCellID)
        collectionView.allowsMultipleSelection = allowsMultipleSelection
        collectionView.backgroundColor = color
        
        // Data
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil).enumerateObjects({ (collection, index, stop) in
            print("Collection: \(collection.localizedTitle!)")
            if collection.localizedTitle != nil && ["相机胶卷", "Camera Roll"].contains(collection.localizedTitle!) {
                self.titleView.label.text = "相机胶卷"
                self.titleView.layoutTitleView()
                
                self.assetCollections.insert(collection, at: 0)
                PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects({ (asset, index, stop) in
                    if asset.mediaType == .image {
//                        print("Append asset");
                        self.assets.append(asset)
                    }
                })
            } else if let title = collection.localizedTitle {
                if self.assetCollectionTitleDict.values.contains(title) || self.assetCollectionTitleDict[title] != nil {
//                    print("Append collection")
                    self.assetCollections.append(collection)
                }
            }
        })
        
        PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).enumerateObjects({
            self.assetCollections.append($0.0)
//            print("Collection: \(collection.localizedTitle!)")
        })
    }
    
    @objc fileprivate func cancelButtonClicked(_ sender: AnyObject) {
        if isNavigationRootController {
            dismiss(animated: true) {
                self.delegate?.imagePickerControllerDidCancel?(self)
            }
        } else {
            _ = navigationController?.popViewController(animated: true)
            delegate?.imagePickerControllerDidCancel?(self)
        }
    }
    
    @objc fileprivate func rightButtonClicked(_ sender: AnyObject) {
        print("rightButtonClicked")
        var infos = [[String : AnyObject]]()
        for indexPath in selectedIndexPaths {
            let asset = assets[indexPath.row]
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: imageTargetSize, contentMode: .aspectFill, options: options) {
                if let image = $0.0 {
                    infos.append([SWImagePickerControllerImage : image, SWImagePickerControllerAssetLocalIdentifier : asset.localIdentifier as AnyObject])
                }
            }
            print("After requesting image")
        }
        print("After for loop")
        if isNavigationRootController {
            dismiss(animated: true) {
                self.delegate?.imagePickerController(self, didFinishPickingImageWithInfos: infos)
            }
        } else {
            _ = navigationController?.popViewController(animated: true)
            delegate?.imagePickerController(self, didFinishPickingImageWithInfos: infos)
        }
        
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SWImagePickerController.imagePickerCellID, for: indexPath)
        
        let asset = assets[indexPath.row]
        if let imagePickerCell = cell as? SWImagePickerCell {
            imageManager.requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: nil) {
                if let image = $0.0 {
                    imagePickerCell.imageView.image = image
                }
            }
            if cell.isSelected {
                if allowsMultipleSelection {
                    let imageName = selectedIndexPaths.count >= maxSelectionCount ? "Unselectable" : "Selectable"
                    imagePickerCell.selectImageView.image = UIImage(named: imageName)
                    
                    let index = selectedIndexPaths.index(of: indexPath)!.advanced(by: 1)
                    imagePickerCell.selectLabel.text = String(index)
                    imagePickerCell.selectLabel.isHidden = false
                } else {
                    imagePickerCell.selectImageView.image = #imageLiteral(resourceName: "Check_blue")
                    imagePickerCell.selectLabel.isHidden = true
                }
            } else {
                updateNotSelectedCell(imagePickerCell)
            }
        }
        
        return cell
    }
    
    private func updateNotSelectedCell(_ cell: SWImagePickerCell) {
        if allowsMultipleSelection {
            let imageName = selectedIndexPaths.count >= maxSelectionCount ? "Unselectable" : "Selectable"
            cell.selectImageView.image = UIImage(named: imageName)
            cell.selectLabel.isHidden = true
        } else {
            cell.selectImageView.image = #imageLiteral(resourceName: "Selectable")
            cell.selectLabel.isHidden = true
        }
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if allowsMultipleSelection {
            if !selectedIndexPaths.contains(indexPath) && selectedIndexPaths.count >= maxSelectionCount {
                return false
            }
        } else {
            // When multiple selection is not allowed, taping the selected cell to deselect it is not allowed
            // Reload the selected cell here to deselect it
            let cell = collectionView.cellForItem(at: indexPath)!
            if cell.isSelected {
                collectionView.reloadItems(at: [indexPath]) // to become not selected
                selectedIndexPaths.removeAll()
                return false
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select")
        selectedIndexPaths.append(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? SWImagePickerCell {
            if allowsMultipleSelection {
                cell.selectLabel.text = String(selectedIndexPaths.count)
                cell.selectLabel.isHidden = false
            } else {
                cell.selectImageView.image = #imageLiteral(resourceName: "Check_blue")
                cell.selectLabel.isHidden = true
            }
        }
        if allowsMultipleSelection && selectedIndexPaths.count == maxSelectionCount {
            for indexPath2 in collectionView.indexPathsForVisibleItems {
                if !selectedIndexPaths.contains(indexPath2),
                    let imagePickerCell = collectionView.cellForItem(at: indexPath2) as? SWImagePickerCell {
                    updateNotSelectedCell(imagePickerCell)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselect")
        selectedIndexPaths.remove(at: selectedIndexPaths.index(of: indexPath)!)
        collectionView.reloadItems(at: [indexPath])
        for (i, anIndexPath) in selectedIndexPaths.enumerated() {
            if let cell = collectionView.cellForItem(at: anIndexPath) as? SWImagePickerCell {
                cell.selectLabel.text = String(i + 1)
            }
        }
        if allowsMultipleSelection && selectedIndexPaths.count == maxSelectionCount - 1 {
            for indexPath2 in collectionView.indexPathsForVisibleItems {
                if !selectedIndexPaths.contains(indexPath2),
                    let imagePickerCell = collectionView.cellForItem(at: indexPath2) as? SWImagePickerCell {
                    updateNotSelectedCell(imagePickerCell)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: SWImagePickerController.album_cell_id, for: indexPath) as? SWImagePickerAlbumCell {
            
            let collection = assetCollections[indexPath.row]
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            if let asset = result.firstObject {
                let size = CGSize(width: SWImagePickerAlbumCell.cellHeight, height: SWImagePickerAlbumCell.cellHeight)
                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) {
                    cell.previewImageView.image = $0.0
                }
            } else {
                cell.previewImageView.image = #imageLiteral(resourceName: "Blank_image")
            }
            cell.albumTitleLabel.text = assetCollectionTitleDict[collection.localizedTitle!] ?? collection.localizedTitle
            cell.photosCountLabel.text = "\(result.count)"
            
            return cell
        }
        
        fatalError("Can not return a cell")
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SWImagePickerAlbumCell.cellHeight
    }
    
    fileprivate var selectedAssetCollectionIndex: Int = 0
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row != selectedAssetCollectionIndex {
            // Different album
            selectedIndexPaths.removeAll()
            
            let collection = assetCollections[indexPath.row]
            assets.removeAll()
            PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects({
                if $0.0.mediaType == .image {
                    self.assets.append($0.0)
                }
            })
            titleView.label.text = assetCollectionTitleDict[collection.localizedTitle!] ?? collection.localizedTitle
            titleView.imageView.image = UIImage(named: "Arrow_down_black")
            titleView.layoutTitleView()
            
            selectedAssetCollectionIndex = indexPath.row
        }
        showNavigationTableView(false)
    }
    
    // MARK: - SWImagePickerTitleViewDelegate
    
    func imagePickerTitleViewTapped(_ titleView: SWImagePickerTitleView) {
        showNavigationTableView(navigationTableView.transform.ty < 0)
        let imageName = navigationTableView.frame.origin.y < 0 ? "Arrow_down_black" : "Arrow_up_black"
        titleView.imageView.image = UIImage(named: imageName)
        titleView.layoutTitleView()
    }
    
    fileprivate func showNavigationTableView(_ show: Bool) {
        collectionView.scrollsToTop = !show
        
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationTableView.transform.ty = show ? 0 : -self.view.bounds.size.height
        }) 
    }
}

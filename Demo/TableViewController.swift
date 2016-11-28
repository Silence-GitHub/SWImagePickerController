//
//  TableViewController.swift
//  SWImagePickerController
//
//  Created by Kaibo Lu on 2016/11/25.
//  Copyright © 2016年 Kaibo Lu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    // MARK: - Table view data source
    
    fileprivate let list = ["Push. Single photo",
                            "Push. Multiple photos",
                            "Present. Single photos",
                            "Present. Multiple photos"]

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let collectionVC = segue.destination as? CollectionViewController
            else { return }
        
        switch indexPath.row {
        case 0:
            collectionVC.selectImageType = .PushSingle
        case 1:
            collectionVC.selectImageType = .PushMultiple
        case 2:
            collectionVC.selectImageType = .PresentSingle
        default:
            collectionVC.selectImageType = .PresentMultiple
        }
    }
}

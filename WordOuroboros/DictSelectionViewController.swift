//
//  DictSelectionViewController.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/11.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

protocol DictSelectionViewControllerDelegate : class {
    func didSelectDict(dict:WordData)
}

class DictSelectionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    let dicts:[WordData] = [WordData.TOEFLWordsData(),WordData.IdiomWordsData()]
    weak var delegate:DictSelectionViewControllerDelegate?
}

extension DictSelectionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dicts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DictCell") as! UITableViewCell
        let data = dicts[indexPath.row]
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = data.randomWord()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectDict(dicts[indexPath.row])
    }

}
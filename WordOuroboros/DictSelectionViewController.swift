//
//  DictSelectionViewController.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/11.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

protocol DictSelectionViewControllerDelegate : class {
    func didSelectCorpus(corpus:WordCorpus)
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
    
    let corpora:[WordCorpus] = Corpora
    weak var delegate:DictSelectionViewControllerDelegate?
}

extension DictSelectionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return corpora.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DictCell") as! UITableViewCell
        let corpus = corpora[indexPath.row]
        cell.textLabel?.text = corpus.name
        cell.detailTextLabel?.text = corpus.sample
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectCorpus(corpora[indexPath.row])
    }

}
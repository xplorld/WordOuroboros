//
//  WordHistoryTableViewController.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/13.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

protocol WordHistoryTableViewControllerDelegate: class {
    //TODO: set for append new
    var wordHistory:[WordType] {get}
    func didSelectWord(word:WordType)
    func addWord(# fromWord:WordType?) -> Bool
}

class WordHistoryTableViewController: UIViewController {
    
    let SECTIONS_COUNT = 2
    let WORD_HISTORY_SECTION_INDEX = 0
    let NEW_WORD_SECTION_INDEX = 1
    
    @IBOutlet var tableView:UITableView!
    weak var delegate:WordHistoryTableViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnSwipe = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = WOColor.textColor
    }
    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController?.navigationBarHidden ?? false
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        showDevelopingAlert("分享",controller: self)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension WordHistoryTableViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
            
        case WORD_HISTORY_SECTION_INDEX:
            let word = delegate.wordHistory[indexPath.row]
            delegate.didSelectWord(word)
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            
        case NEW_WORD_SECTION_INDEX:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if delegate.addWord(fromWord: delegate.wordHistory.last) {
                tableView.insertRowsAtIndexPaths(
                    [NSIndexPath(forRow: delegate.wordHistory.count - 1, inSection: WORD_HISTORY_SECTION_INDEX)]
                    , withRowAnimation: .Top)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            } else {
//                tableView.reloadData()
            }
            
        default: break
        }
        
    }
}

extension WordHistoryTableViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return SECTIONS_COUNT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case WORD_HISTORY_SECTION_INDEX: return delegate.wordHistory.count
        case NEW_WORD_SECTION_INDEX: return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case WORD_HISTORY_SECTION_INDEX:
            let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath) as! WordHistoryCellTableViewCell
            var word = delegate.wordHistory[indexPath.row]
            cell.wordLabel.text = word.string
            cell.backgroundColor = word.color
            return cell
        case NEW_WORD_SECTION_INDEX:
            let cell = tableView.dequeueReusableCellWithIdentifier("AddWordCell") as! AddWordTableViewCell
            cell.backgroundColor = WOColor.getColor()
            return cell
        default:
            fatalError("not gonna happen: wordHistoryTVC not consistent")
        }
    }
}
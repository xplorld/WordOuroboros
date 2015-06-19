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
}

class WordHistoryTableViewController: UIViewController {

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func actionButtonTapped(sender: AnyObject) {
        showDevelopingAlert("分享")
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension WordHistoryTableViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let word = delegate.wordHistory[indexPath.row]
        delegate.didSelectWord(word)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension WordHistoryTableViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: ...
        return delegate.wordHistory.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath) as! WordHistoryCellTableViewCell
        var word = delegate.wordHistory[indexPath.row]
        cell.wordLabel.text = word.string
        cell.backgroundColor = word.color
        return cell
    }
}
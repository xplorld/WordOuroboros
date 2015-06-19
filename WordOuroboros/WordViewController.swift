//
//  WordViewController.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {
    
    @IBOutlet var slidableView:SlidableView!
    @IBOutlet weak var toolBarView: ToolBarView!
    var corpusData = Corpora[0].data
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareSlidableView()
        self.prepareToolBarView()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toolBarTapHandler")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
}
//MARK - shake handling
extension WordViewController {
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if event.subtype == UIEventSubtype.MotionShake {
            //here detected shake
            refreshWithRandomWord()
        }
        if super.respondsToSelector("motionEnded:withEvent:") {
            super.motionEnded(motion, withEvent: event)
        }
    }
}


//MARK: - tool bar view related
extension WordViewController : UIAlertViewDelegate {
    func prepareToolBarView() {
        let buttonInfo = [
            ("books","dictSelectionDidTap"),
            ("refresh","refreshWithRandomWord"),
            ("history","historyDidTap"),
            ("pencil","inputDidTap")
        ]
        
        for (name,action) in buttonInfo {
            let button = UIButton()
            button.setImage(UIImage(named: name)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            button.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
            button.tintColor = UIColor.whiteColor()
            toolBarView.pushButton(button)
        }
        
        toolBarView.hidden = true
        toolBarView.alpha = 0
        
        self.view.bringSubviewToFront(toolBarView)
        
    }
    func toolBarTapHandler() {
        let view = toolBarView
        view.hidden = false
        UIView.animateWithDuration(0.2, animations: {view.alpha = view.alpha == 0 ? 1 : 0 }, completion: {_ in if view.alpha == 0 {view.hidden = true} })
    }
    func dictSelectionDidTap() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("dictSelectionController") as! DictSelectionViewController
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    func refreshWithRandomWord() {
        let word = corpusData.randomWord()
        dispatch_async(dispatch_get_main_queue()) {
            [unowned self] in
            let view = self.slidableView.dequeueView() as! WordView
            view.word = word
            self.slidableView.setCurrentView(view)
        }
    }
    func historyDidTap() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WordHistoryTableViewController") as! WordHistoryTableViewController
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    func inputDidTap() {
        let alert = UIAlertView(title: "输入词语", message: nil, delegate: self, cancelButtonTitle: "取消")
        alert.addButtonWithTitle("确定")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            if let text = alertView.textFieldAtIndex(0)?.text {
                if !isEmpty(text) {
                    let word = corpusData.wordFromLiteral(text)
                    let view = slidableView.dequeueView() as! WordView
                    view.word = word
                    slidableView.setCurrentView(view)
                }
            }
        }
    }
}

//MARK: - SlidableViewDelegate
extension WordViewController : SlidableViewDelegate {
    func prepareSlidableView() {
        slidableView.slidableViewDelegate = self
        slidableView.queueViewMaker = {
            let view = NSBundle.mainBundle().loadNibNamed("WordView", owner: self, options: nil).first as! WordView
            view.frame.size = $0.frame.size //$0 is the slidable view
            return view
        }
        self.view.addSubview(slidableView)
        refreshWithRandomWord()
        
    }
    
    func viewOfDirection(direction: PanGestureDirection, slidableView: SlidableView, currentView: UIView) -> UIView? {
        let oldWord = (currentView as! WordView).word
        
        let newWord:WordType?
        if direction.isVertical() {
            newWord = corpusData.wordBesidesWord(oldWord)
        } else if direction == .Left {
            newWord = corpusData.wordNextToWord(oldWord)
        } else {
            //.Right
            newWord = corpusData.wordBeforeWord(oldWord)
        }
        
        if newWord != nil {
            let view = slidableView.dequeueView() as! WordView
            view.word = newWord!
            return view
        } else {
            return nil
        }
    }
}

//MARK: - DictSelectionViewControllerDelegate
extension WordViewController : DictSelectionViewControllerDelegate {
    func didSelectCorpus(corpus: WordCorpus) {
        self.corpusData = corpus.data
        refreshWithRandomWord()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: - WordHistoryTableViewControllerDelegate
extension WordViewController : WordHistoryTableViewControllerDelegate {
    var wordHistory: [WordType] {
        return corpusData.wordHistory
    }
    func didSelectWord(word: WordType) {
        let view = slidableView.dequeueView() as! WordView
        view.word = word
        slidableView.setCurrentView(view)
    }
    func slidableViewDidScroll(slidableView: SlidableView) {
        if !toolBarView.hidden {
            //dismiss tool bar
            toolBarTapHandler()
        }
    }
}





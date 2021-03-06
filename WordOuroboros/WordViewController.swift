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
//MARK: - status bar handling
extension WordViewController {
    override func prefersStatusBarHidden() -> Bool {
        return (toolBarView?.alpha == 0) ?? false
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
}
//MARK: - shake handling
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
extension WordViewController {
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
        setNeedsStatusBarAppearanceUpdate()
        
        self.view.bringSubviewToFront(toolBarView)
        
    }
    func toolBarTapHandler() {
        let view = toolBarView
        if view.hidden {
            view.hidden = false
            UIView.animateWithDuration(0.2, animations:
                {
                    view.alpha = 1
                    self.setNeedsStatusBarAppearanceUpdate()
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                view.alpha = 0
                self.setNeedsStatusBarAppearanceUpdate()
                }) //completion:
                {_ in view.hidden = true}
        }
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
        let alert = UIAlertController(title: "输入词语", message: nil, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "确定", style: .Default, handler: {
            [unowned self] _ in
            self.setWordFromLiteral(literal: (alert.textFields![0] as! UITextField).text)
            })
        okAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {_ in})

        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = "词语"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                okAction.enabled = textField.text != ""
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func setWordFromLiteral(literal text:String) {
        let word = corpusData.wordFromLiteral(text)
        let view = slidableView.dequeueView() as! WordView
        view.word = word
        slidableView.setCurrentView(view)
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
    func slidableViewWillScroll(slidableView: SlidableView) {
        if !toolBarView.hidden {
            //dismiss tool bar
            toolBarTapHandler()
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
    func addWord(fromWord word: WordType?) -> Bool {
        if let prev = word,
            let next = corpusData.wordNextToWord(prev) {
                didSelectWord(next)
                return true
        } else {
            //            refreshWithRandomWord()
            return false
        }
    }
}





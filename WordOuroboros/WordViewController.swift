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
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapHandler")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    func prepareSlidableView() {
        slidableView.slidableViewDelegate = self
        slidableView.queueViewMaker = {
            let view = NSBundle.mainBundle().loadNibNamed("WordView", owner: self, options: nil).first as! WordView
            view.frame.size = $0.frame.size //$0 is the slidable view
            return view
        }
        self.view.addSubview(slidableView)
        refreshDidTap()

    }
    func prepareToolBarView() {
        let buttonInfo = [
            ("books","dictSelectionDidTap"),
            ("refresh","refreshDidTap"),
            ("history","historyDidTap")
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
    func tapHandler() {
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
    func refreshDidTap() {
        let view = slidableView.dequeueView() as! WordView
        view.word = corpusData.randomWord()
        slidableView.setCurrentView(view)
    }
    func historyDidTap() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WordHistoryTableViewController") as! WordHistoryTableViewController
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
    
}

extension WordViewController : SlidableViewDelegate {
    
    func getViewFromSlidable() -> WordView {
        let view = slidableView.dequeueView() as! WordView
        view.frame.size = self.slidableView.frame.size
        return view
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
            let view = getViewFromSlidable()
            view.word = newWord!
            return view
        } else {
            return nil
        }
    }
}

extension WordViewController : DictSelectionViewControllerDelegate {
    func didSelectCorpus(corpus: WordCorpus) {
        self.corpusData = corpus.data
        refreshDidTap()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

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
            tapHandler()
        }
    }
}





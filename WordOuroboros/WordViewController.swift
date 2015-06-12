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
    var data = WordData.TOEFLWordsData()
    var tapGestureRecognizer:UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareSlidableView()
        self.prepareToolBarView()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapHandler:")
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
            ("refresh","refreshDidTap")
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
    func tapHandler(sender:UIGestureRecognizer) {
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
        view.backgroundColor = WOColor.getColor()
        view.text = data.randomWord() ?? ""
        slidableView.setCurrentView(view)
    }
    
}

extension WordViewController : SlidableViewDelegate {
    
    func makeView() -> WordView {
        let view = slidableView.dequeueView() as! WordView
        view.frame.size = self.slidableView.frame.size
        view.backgroundColor = WOColor.getColor()
        return view
    }
    
    func viewOfDirection(direction: PanGestureDirection, slidableView: SlidableView, currentView: UIView) -> UIView? {
        let oldWord = (currentView as! WordView).text
        
        let newWord:String?
        if direction.isVertical() {
            newWord = data.wordBesidesWord(oldWord)
        } else if direction == PanGestureDirection.Left {
            newWord = data.wordNextToWord(oldWord)
        } else {
            //.Right
            newWord = data.wordBeforeWord(oldWord)
        }
        
        if newWord != nil {
            let view = makeView()
            view.text = newWord!
            return view
        } else {
            return nil
        }
    }
}

extension WordViewController : DictSelectionViewControllerDelegate {
    func didSelectDict(dict:WordData) {
        self.data = dict
        refreshDidTap()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}









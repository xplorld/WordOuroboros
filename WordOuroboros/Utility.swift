//
//  Utility.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/13.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

func JSONObjectFromFile(path:String) -> AnyObject? {
    let name = path.stringByDeletingPathExtension
    let type = path.pathExtension
    if let
        truePath = NSBundle.mainBundle().pathForResource(name, ofType: type),
        data = NSData(contentsOfFile:truePath) {
            return NSJSONSerialization.JSONObjectWithData(data,options: .AllowFragments, error: nil)
    }
    return nil
}

func showDevelopingAlert(moduleName: String,# controller: UIViewController) {
    let alert = UIAlertController(title: "报警啦!", message: "\(moduleName)功能开发中", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "好吧", style: .Cancel, handler: nil))
    controller.presentViewController(alert, animated: true, completion: nil)
}
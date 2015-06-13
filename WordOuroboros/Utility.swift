//
//  Utility.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/13.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import Foundation

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
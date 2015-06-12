//
//  WordData.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

private var _TOEFLWordsData:WordData?
private var _IdiomWordsData:WordData?

class WordData {
    let name:String
    var usedWords:[String] = []
    var headMap:[Character:[String]] = [:]
    var tailMap:[Character:[String]] = [:]
    func setWords(words:[String]) {
        for word in words {
            if let head = first(word) {
                if headMap[head] == nil {
                    headMap[head] = []
                }
                headMap[head]!.append(word)
            }
            
            if let tail = last(word) {
                if tailMap[tail] == nil {
                    tailMap[tail] = []
                }
                tailMap[tail]!.append(word)
            }
        }
    }
    init(name:String) {
        self.name = name
    }
    

    class func TOEFLWordsData() -> WordData {
        if _TOEFLWordsData != nil {
            return _TOEFLWordsData!
        }
        
        let data = WordData(name: "TOEFL 单词")
        data.setWords(NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("toefl", ofType: "json")!)!, options: .AllowFragments, error: nil) as? [String] ?? [])
        _TOEFLWordsData = data
        return data
    }
    class func IdiomWordsData() -> WordData {
        if _IdiomWordsData != nil {
            return _IdiomWordsData!
        }
        let data = WordData(name:"成语")
        data.setWords(NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("chengyu", ofType: "json")!)!, options: .AllowFragments, error: nil) as? [String] ?? [])
        _IdiomWordsData = data
        return data
    }
}

//word providing methods
//interface
extension WordData {
    private func wordOfRelationshipToWord(old:String,relation:WordRelationship) -> String? {
        if old == "" {
            return nil
        }
        if find(usedWords, old) == nil {
            usedWords.append(old)
        }
        
        let (oldPicker,newPicker) = charPosition(relation)
        if let oldChar = oldPicker(old) {
            return newPicker(oldChar).filter {!contains(self.usedWords, $0)}.first
        }
        return nil
    }
    func wordBeforeWord(old:String) -> String? {
        return wordOfRelationshipToWord(old, relation: .Before)
    }
    func wordNextToWord(old:String) -> String? {
        return wordOfRelationshipToWord(old, relation: .After)
    }
    func wordBesidesWord(old:String) -> String? {
        return wordOfRelationshipToWord(old, relation: .Besides)
    }
    func randomWord() -> String? {
        if headMap.isEmpty {
            return nil
        }
        let i = Int(arc4random_uniform(UInt32(headMap.count)))
        let key = Array(headMap.keys)[i]
        let strs = headMap[key]!
        let j = Int(arc4random_uniform(UInt32(strs.count)))
        return strs[j]
    }
    
    private func charPosition(relationship:WordRelationship) -> (old:(String)->Character?,new:(Character)->[String]) {
        var lastSelector:(Character)->[String] = {self.tailMap[$0] ?? []}
        let firstSelector:(Character)->[String] = {self.headMap[$0] ?? []}
        
        switch relationship {
        case .Before:
            return (first,lastSelector)
        case .After:
            return (last,firstSelector)
        case .Besides:
            return (first,firstSelector)
        case .Irrelevant:
            fatalError("hehe")
            
        }
    }
}


enum WordRelationship {
    case Before
    case After
    case Besides
    case Irrelevant
    
}


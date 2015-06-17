//
//  WordCorpus.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

class WordType : Equatable {
    let string:String
    let detailedString:String?
    lazy var color:UIColor = {
        WOColor.getColor()
        }()
    init(_ s:String) {
        string = s
        detailedString = nil
    }
    init(s:String,detailedString:String?) {
        self.string = s
        self.detailedString = detailedString
    }
}
func ==(lhs:WordType,rhs:WordType) -> Bool {
    return lhs.string == rhs.string
}

/**
array of WordCorpus like

WordCorpus(
name:"TOEFL 词汇",
path:"toefl.json",
sample:"Gothic")
*/
let Corpora:[WordCorpus] = (JSONObjectFromFile("corpusList.json") as! [[String:AnyObject]])
    .map{WordCorpus(
        name:$0["name"] as! String,
        path:$0["path"] as! String,
        sample:WordType($0["sample"] as! String),
        stringKey:$0["stringKey"] as? String,
        detailedStringKeys:$0["detailedStringKeys"] as? [String]
        )}


/**a corpus.

:IMPORTANT:

this class does not hold strong reference of `data`, for the sake of saving memory.

User of this class shall hold strong reference for both `WordCorpus` and `WordCorpus.data`

*/
class WordCorpus {
    let path:String
    let name:String
    let sample:WordType
    private let stringKey:String?
    private let detailedStringKeys:[String]?
    init(name: String,path: String,sample:WordType,stringKey:String?,detailedStringKeys:[String]?) {
        self.name = name
        self.path = path
        self.sample = sample
        self.stringKey = stringKey
        self.detailedStringKeys = detailedStringKeys
    }
    /**`lazy weak` data object*/
    var data:WordCorpusData {
        
        if (_data == nil) {
//            println("start processing json")
//            let time = CFAbsoluteTimeGetCurrent()
            
            let data = WordCorpusData()
            if stringKey == nil {
                let json = JSONObjectFromFile(self.path) as! NSArray
                var words:[WordType] = []
                for wordLit in json {
                    words.append(WordType(wordLit as! String))
                }
                data.words = words
            } else {
                let json = JSONObjectFromFile(self.path) as! NSArray
                var words:[WordType] = []
                for wordDict in json {
                    let theDict = wordDict as! NSDictionary
                    let string = theDict[self.stringKey!] as! String
                    let detail: String
                    if let keys = self.detailedStringKeys {
                        //" ".join(strings) is extremely slow
                        detail = keys.map{theDict[$0] as? String ?? ""}.reduce("", combine: {$0+" "+$1})
                    } else {
                        detail = ""
                    }
                    words.append(WordType(
                        s: string,
                        detailedString:detail))
                }
                data.words = words
            }
//            println("done.\ntime \(CFAbsoluteTimeGetCurrent() - time)")
            _data = data
            return data
        }
        return _data!
    }
    private weak var _data:WordCorpusData?
}
class WordCorpusData {
    typealias CharacterType = Character
    var usedWords:[WordType] = []
    
    ///[Character:[String]]
    var words:[WordType] = [] {
        didSet {
            headMap.removeAll(keepCapacity: false)
            tailMap.removeAll(keepCapacity: false)
            for word in words {
                addWord(word)
            }
        }
    }
    private func addWord(word:WordType) {
        if let head = first(word.string) {
            if headMap[head] == nil {
                headMap[head] = []
            }
            headMap[head]!.append(word)
        }
        
        if let tail = last(word.string) {
            if tailMap[tail] == nil {
                tailMap[tail] = []
            }
            tailMap[tail]!.append(word)
        }
    }
    var headMap:[CharacterType:[WordType]] = [:]
    var tailMap:[CharacterType:[WordType]] = [:]
    
    //TODO: change history from list to graph (like git?)
    var wordHistory:[WordType] = []
    
    deinit {
        println("deinit data like \(words.first?.string)")
    }
}

//word providing methods
//interface
extension WordCorpusData {
    private func wordOfRelationshipToWord(old:WordType,relation:WordRelationship) -> WordType? {
        if isEmpty(old.string) {
            return nil
        }
        let (oldPicker,newPicker) = charPosition(relation)
        if let
            oldChar = oldPicker(old),
            new = (newPicker(oldChar).filter{[weak self] in !contains(self!.usedWords, $0)}.first) {
                usedWords.append(new)
                return new
        }
        return nil
    }
    func wordBeforeWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .Before) {
            if let index = find(wordHistory, old) {
                //"ab" with ["eg","gb","bc","cf"] becomes ["ab","bc","cf"]
                wordHistory.removeRange(0..<index)
                wordHistory.insert(theWord, atIndex: 0)
            } else {
                wordHistory = [theWord,old]
            }
            return theWord
        }
        return nil
    }
    func wordNextToWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .After) {
            if let index = find(wordHistory, old) {
                wordHistory.removeRange((index+1)..<wordHistory.endIndex)
                wordHistory.append(theWord)
            } else {
                wordHistory = [old,theWord]
            }
            return theWord
        }
        return nil
    }
    func wordBesidesWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .Besides) {
            if let index = find(wordHistory, old) {
                wordHistory.removeRange(index..<wordHistory.endIndex)
                wordHistory.append(theWord)
            } else {
                wordHistory = [theWord]
            }
            return theWord
        }
        return nil
    }
    func wordFromLiteral(string:String) -> WordType? {
        if let word = (words.filter{$0.string == string}).first {
            if !contains(wordHistory, word) {
                wordHistory = [word]
            }
            return word
        }
        let word = WordType(string)
        addWord(word)
        wordHistory = [word]
        return word
    }
    func randomWord() -> WordType? {
        if headMap.isEmpty {
            return nil
        }
        let i = Int(arc4random_uniform(UInt32(headMap.count)))
        let key = Array(headMap.keys)[i]
        let strs = headMap[key]!
        let j = Int(arc4random_uniform(UInt32(strs.count)))
        let word = strs[j]
        wordHistory = [word]
        usedWords.append(word)
        return word
    }
    
    
    private func charPosition(relationship:WordRelationship) -> (old:(WordType)->CharacterType?,new:(CharacterType)->[WordType]) {
        let firstChar:(WordType)->CharacterType? = {first($0.string)}
        let lastChar:(WordType)->CharacterType? = {last($0.string)}
        let lastSelector:(CharacterType)->[WordType] = {[weak self] in self!.tailMap[$0] ?? []}
        let firstSelector:(CharacterType)->[WordType] = {[weak self] in self!.headMap[$0] ?? []}
        
        switch relationship {
        case .Before:
            return (firstChar,lastSelector)
        case .After:
            return (lastChar,firstSelector)
        case .Besides:
            return (firstChar,firstSelector)
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


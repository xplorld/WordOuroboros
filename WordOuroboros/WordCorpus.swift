//
//  WordCorpus.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

///can switch to any type conforms to `CollectionType`
typealias WordType = String
typealias CharacterType = WordType.Generator.Element

/**
array of WordCorpus like

WordCorpus(
name:"TOEFL 词汇",
path:"toefl.json",
sample:"Gothic")
*/
let Corpora:[WordCorpus] = (JSONObjectFromFile("corpusList.json") as! [[String:String]])
    .map{WordCorpus(name:$0["name"]!,path:$0["path"]!,sample:$0["sample"]!)}


/**a corpus.

:IMPORTANT:

this class does not hold strong reference of `data`, for the sake of saving memory.

User of this class shall hold strong reference for both `WordCorpus` and `WordCorpus.data`

*/
class WordCorpus {
    let path:String
    let name:String
    let sample:WordType
    init(name: String,path: String,sample:WordType) {
        self.name = name
        self.path = path
        self.sample = sample
    }
    /**`lazy weak` data object*/
    var data:WordCorpusData {
        if (_data == nil) {
            let data = WordCorpusData()
            let json = JSONObjectFromFile(self.path) as! [String]
            data.setWords(json)
            _data = data
            return data
        }
        return _data!
    }
    private weak var _data:WordCorpusData?
}
class WordCorpusData {
    var usedWords:[WordType] = []
    
    ///[Character:[String]]
    var headMap:[CharacterType:[WordType]] = [:]
    var tailMap:[CharacterType:[WordType]] = [:]
    private func setWords(words:[WordType]) {
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
    
    //TODO: change history from list to graph (like git?)
    var wordHistory:[WordType] = []
}

//word providing methods
//interface
extension WordCorpusData {
    private func wordOfRelationshipToWord(old:WordType,relation:WordRelationship) -> WordType? {
        if old == "" {
            return nil
        }
        let (oldPicker,newPicker) = charPosition(relation)
        if let
            oldChar = oldPicker(old),
            new = (newPicker(oldChar).filter{!contains(self.usedWords, $0)}.first) {
                usedWords.append(new)
                return new
        }
        return nil
    }
    func wordBeforeWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .Before) {
            let index = find(wordHistory, old)!
            //"ab" with ["eg","gb","bc","cf"] becomes ["ab","bc","cf"]
            wordHistory.removeRange(0..<index)
            wordHistory.insert(theWord, atIndex: 0)
            
            return theWord
        }
        return nil
    }
    func wordNextToWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .After) {
            let index = find(wordHistory, old)!
            wordHistory.removeRange((index+1)..<wordHistory.endIndex)
            wordHistory.append(theWord)
            return theWord
        }
        return nil
    }
    func wordBesidesWord(old:WordType) -> WordType? {
        if let theWord = wordOfRelationshipToWord(old, relation: .Besides) {
            let index = find(wordHistory, old)!
            wordHistory.removeRange(index..<wordHistory.endIndex)
            wordHistory.append(theWord)
            return theWord
        }
        return nil
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
        var lastSelector:(CharacterType)->[WordType] = {self.tailMap[$0] ?? []}
        let firstSelector:(CharacterType)->[WordType] = {self.headMap[$0] ?? []}
        
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


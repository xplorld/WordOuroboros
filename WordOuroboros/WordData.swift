//
//  WordCorpusData.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

typealias WordType = String
typealias CharacterType = WordType.Generator.Element

let Corpora:[WordCorpus] = [
    WordCorpus(name:"TOEFL 词汇",path:"toefl.json",sample:"Gothic"),
    WordCorpus(name:"成语",path:"chengyu.json",sample:"偃苗助长")
]

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
            let fileName = self.path.stringByDeletingPathExtension
            let type = self.path.pathExtension
            let truePath = NSBundle.mainBundle().pathForResource(fileName, ofType: type)!
            let json = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: truePath)!, options: .AllowFragments, error: nil) as? [String] ?? []
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
    //[Character:[String]]
    var headMap:[CharacterType:[WordType]] = [:]
    var tailMap:[CharacterType:[WordType]] = [:]
    func setWords(words:[WordType]) {
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
    deinit {
        println("corpus data deinited,sample \(headMap.values.first?.first)")
    }
}

//word providing methods
//interface
extension WordCorpusData {
    private func wordOfRelationshipToWord(old:WordType,relation:WordRelationship) -> WordType? {
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
    func wordBeforeWord(old:WordType) -> WordType? {
        return wordOfRelationshipToWord(old, relation: .Before)
    }
    func wordNextToWord(old:WordType) -> WordType? {
        return wordOfRelationshipToWord(old, relation: .After)
    }
    func wordBesidesWord(old:WordType) -> WordType? {
        return wordOfRelationshipToWord(old, relation: .Besides)
    }
    func randomWord() -> WordType? {
        if headMap.isEmpty {
            return nil
        }
        let i = Int(arc4random_uniform(UInt32(headMap.count)))
        let key = Array(headMap.keys)[i]
        let strs = headMap[key]!
        let j = Int(arc4random_uniform(UInt32(strs.count)))
        return strs[j]
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


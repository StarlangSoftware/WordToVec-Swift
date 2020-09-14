//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 14.09.2020.
//

import Foundation
import Corpus
import Dictionary

public class Vocabulary{
    
    private var __vocabulary: [VocabularyWord] = []
    private var __table: [Int] = []

    /**
    Constructor for the Vocabulary class. For each distinct word in the corpus, a VocabularyWord
    instance is created. After that, words are sorted according to their occurrences. Unigram table is constructed,
    where after Huffman tree is created based on the number of occurrences of the words.

    - Parameter corpus : Corpus used to train word vectors using Word2Vec algorithm.
    */
    public init(corpus: Corpus){
        let wordList = corpus.getWordList()
        for word in wordList{
            self.__vocabulary.append(VocabularyWord(name: word.getName(), count: corpus.getCount(word: word)))
        }
        self.__createUniGramTable()
        self.__constructHuffmanTree()
    }

    /**
    Returns number of words in the vocabulary.

    - Returns: Number of words in the vocabulary.
    */
    public func size() -> Int{
        return self.__vocabulary.count
    }

    /**
    Searches a word and returns the position of that word in the vocabulary. Search is done using binary search.

    - Parameter word : Word to be searched.

    - Returns: Position of the word searched.
    */
    public func getPosition(word: Word) -> Int{
        var lo : Int = 0
        var hi : Int = self.__vocabulary.count
        while lo < hi{
            let mid : Int = (lo + hi) / 2
            if self.__vocabulary[mid].getName() < word.getName(){
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        return lo
    }

    /**
    Returns the word at a given index.

    - Parameter index : Index of the word.

    - Returns: The word at a given index.
    */
    public func getWord(index: Int) -> VocabularyWord{
        return self.__vocabulary[index]
    }

    /**
    Constructs Huffman Tree based on the number of occurences of the words.
    */
    public func __constructHuffmanTree(){
        var count : [Int] = Array(repeating: 0, count: self.__vocabulary.count * 2 + 1)
        var code : [Int] = Array(repeating: 0, count: VocabularyWord.MAX_CODE_LENGTH)
        var point : [Int] = Array(repeating: 0, count: VocabularyWord.MAX_CODE_LENGTH)
        var binary : [Int] = Array(repeating: 0, count: self.__vocabulary.count * 2 + 1)
        var parentNode : [Int] = Array(repeating: 0, count: self.__vocabulary.count * 2 + 1)
        for a in 0..<self.__vocabulary.count{
            count[a] = self.__vocabulary[a].getCount()
        }
        for a in self.__vocabulary.count..<self.__vocabulary.count * 2{
            count[a] = 1000000000
        }
        var pos1 : Int = self.__vocabulary.count - 1
        var pos2 : Int = self.__vocabulary.count
        var min1i : Int
        var min2i : Int
        for a in 0..<self.__vocabulary.count - 1{
            if pos1 >= 0{
                if count[pos1] < count[pos2] {
                    min1i = pos1
                    pos1 = pos1 - 1
                } else {
                    min1i = pos2
                    pos2 = pos2 + 1
                }
            } else {
                min1i = pos2
                pos2 = pos2 + 1
            }
            if pos1 >= 0{
                if count[pos1] < count[pos2]{
                    min2i = pos1
                    pos1 = pos1 - 1
                } else {
                    min2i = pos2
                    pos2 = pos2 + 1
                }
            } else {
                min2i = pos2
                pos2 = pos2 + 1
            }
            count[self.__vocabulary.count + a] = count[min1i] + count[min2i]
            parentNode[min1i] = self.__vocabulary.count + a
            parentNode[min2i] = self.__vocabulary.count + a
            binary[min2i] = 1
        }
        for a in 0..<self.__vocabulary.count{
            var b : Int = a
            var i : Int = 0
            while true{
                code[i] = binary[b]
                point[i] = b
                i = i + 1
                b = parentNode[b]
                if b == self.__vocabulary.count * 2 - 2{
                    break
                }
            }
            self.__vocabulary[a].setCodeLength(codeLength: i)
            self.__vocabulary[a].setPoint(index: 0, value: self.__vocabulary.count - 2)
            for b in 0..<i{
                self.__vocabulary[a].setCode(index: i - b - 1, value: code[b])
                self.__vocabulary[a].setPoint(index: i - b, value: point[b] - self.__vocabulary.count)
            }
        }
    }

    /**
    Constructs the unigram table based on the number of occurences of the words.
    */
    public func __createUniGramTable(){
        var total : Double = 0
        self.__table = Array(repeating: 0, count: 2 * self.__vocabulary.count)
        for vocabularyWord in self.__vocabulary{
            total += pow(Double(vocabularyWord.getCount()), 0.75)
        }
        var i : Int = 0
        var d1 : Double = pow(Double(self.__vocabulary[i].getCount()), 0.75) / total
        for a in 0..<2 * self.__vocabulary.count{
            self.__table[a] = i
            if Double(a) / (2 * Double(self.__vocabulary.count) + 0.0) > d1{
                i = i + 1
                d1 += pow(Double(self.__vocabulary[i].getCount()), 0.75) / total
            }
            if i >= self.__vocabulary.count{
                i = self.__vocabulary.count - 1
            }
        }
    }

    /**
    Accessor for the unigram table.

    - Parameter index : Index of the word.

    - Returns: Unigram table value at a given index.
    */
    public func getTableValue(index: Int) -> Int{
        return self.__table[index]
    }

    /**
    Returns size of the unigram table.

    - Returns: Size of the unigram table.
    */
    public func getTableSize() -> Int{
        return self.__table.count
    }
}

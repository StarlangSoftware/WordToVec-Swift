//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 14.09.2020.
//

import Foundation
import Dictionary

public class VocabularyWord : Word{
    
    private var __count: Int
    private var __code: [Int]
    private var __poInt: [Int]
    private var __codeLength: Int
    public static var MAX_CODE_LENGTH = 40

    /**
    Constructor for a VocabularyWord. The constructor gets name and count values and sets the corresponding
    attributes. It also initializes the code and poInt arrays for this word.

    - Parameters:
        - name : Lemma of the word
        - count : Number of occurrences of this word in the corpus
    */
    public init(name: String, count: Int){
        self.__count = count
        self.__code = Array(repeating: 0, count: VocabularyWord.MAX_CODE_LENGTH)
        self.__poInt = Array(repeating: 0, count: VocabularyWord.MAX_CODE_LENGTH)
        self.__codeLength = 0
        super.init(name: name)
    }

    public static func < (lhs: VocabularyWord, rhs: VocabularyWord) -> Bool {
        return lhs.__count < rhs.__count
    }

    public static func == (lhs: VocabularyWord, rhs: VocabularyWord) -> Bool {
        return lhs.__count == rhs.__count
    }

    /**
    Accessor for the count attribute.

    - Returns: Number of occurrences of this word.
    */
    public func getCount() -> Int{
        return self.__count
    }

    /**
    Mutator for codeLength attribute.

    - Parameter codeLength : New value for the codeLength.
    */
    public func setCodeLength(codeLength: Int){
        self.__codeLength = codeLength
    }

    /**
    Mutator for code attribute.

    - Parameters:
        - index : Index of the code
        - value : New value for that indexed element of code.
    */
    public func setCode(index: Int, value: Int){
        self.__code[index] = value
    }

    /**
    Mutator for poInt attribute.

    - Parameters:
        - index : Index of the poInt
        - value : New value for that indexed element of poInt.
    */
    public func setPoint(index: Int, value: Int){
        self.__poInt[index] = value
    }

    /**
    Accessor for the codeLength attribute.

    - Returns: Length of the Huffman code for this word.
    */
    public func getCodeLength() -> Int{
        return self.__codeLength
    }

    /**
    Accessor for poInt attribute.

    - Parameter index : Index of the poInt.

    - Returns: Value for that indexed element of poInt.
    */
    public func getPoint(index: Int) -> Int{
        return self.__poInt[index]
    }

    /**
    Accessor for code attribute.

    - Parameter index : Index of the code.

    - Returns: Value for that indexed element of code.
    */
    public func getCode(index: Int) -> Int{
        return self.__code[index]
    }
}

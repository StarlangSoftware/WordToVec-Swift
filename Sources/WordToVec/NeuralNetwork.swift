//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 14.09.2020.
//

import Foundation
import Math
import Corpus
import Dictionary

public class NeuralNetwork{
    
    private var __wordVectors: Matrix
    private var __wordVectorUpdate: Matrix
    private var __vocabulary: Vocabulary
    private var __parameter: WordToVecParameter
    private var __corpus: Corpus
    private var __expTable: [Double] = []

    private static var EXP_TABLE_SIZE = 1000
    private static var MAX_EXP = 6

    /**
    Constructor for the NeuralNetwork class. Gets corpus and network parameters as input and sets the
    corresponding parameters first. After that, initializes the network with random weights between -0.5 and 0.5.
    Constructs vector update matrix and prepares the exp table.

    - Parameters:
        - corpus : Corpus used to train word vectors using Word2Vec algorithm.
        - parameter : Parameters of the Word2Vec algorithm.
    */
    public init(corpus: Corpus, parameter: WordToVecParameter){
        self.__vocabulary = Vocabulary(corpus: corpus)
        self.__parameter = parameter
        self.__corpus = corpus
        self.__wordVectors = Matrix(row: self.__vocabulary.size(), col: self.__parameter.getLayerSize(), min: -0.5, max: 0.5)
        self.__wordVectorUpdate = Matrix(row: self.__vocabulary.size(), col: self.__parameter.getLayerSize())
        self.__prepareExpTable()
    }

    /**
    Constructs the fast exponentiation table. Instead of taking exponent at each time, the algorithm will lookup
    the table.
    */
    public func __prepareExpTable(){
        self.__expTable = Array(repeating: 0.0, count: NeuralNetwork.EXP_TABLE_SIZE + 1)
        for i in 0..<NeuralNetwork.EXP_TABLE_SIZE{
            self.__expTable[i] = exp((Double(i) / Double(NeuralNetwork.EXP_TABLE_SIZE) * 2.0 - 1.0) * Double(NeuralNetwork.MAX_EXP))
            self.__expTable[i] = self.__expTable[i] / (self.__expTable[i] + 1)
        }
    }

    /**
    Main method for training the Word2Vec algorithm. Depending on the training parameter, CBox or SkipGram algorithm
    is applied.

    - Returns: Dictionary of word vectors.
    */
    public func train() -> VectorizedDictionary{
        let result : VectorizedDictionary = VectorizedDictionary()
        if self.__parameter.isCbow(){
            self.__trainCbow()
        } else {
            self.__trainSkipGram()
        }
        for i in 0..<self.__vocabulary.size(){
            result.addWord(word: VectorizedWord(name: self.__vocabulary.getWord(index: i).getName(), vector: self.__wordVectors.getRowVector(row: i)))
        }
        return result
    }

    /**
    Calculates G value in the Word2Vec algorithm.

    - Parameters:
        - f : F value.
        - alpha : Learning rate alpha.
        - label : Label of the instance.

    - Returns: Calculated G value.
    */
    public func __calculateG(f: Double, alpha: Double, label: Double) -> Double{
        if f > Double(NeuralNetwork.MAX_EXP){
            return (label - 1) * alpha
        } else if f < -Double(NeuralNetwork.MAX_EXP){
            return label * alpha
        } else {
            return (label - self.__expTable[Int((f + Double(NeuralNetwork.MAX_EXP)) *
                Double(NeuralNetwork.EXP_TABLE_SIZE / NeuralNetwork.MAX_EXP / 2))]) * alpha
        }
    }

    /**
    Main method for training the CBow version of Word2Vec algorithm.
    */
    public func __trainCbow(){
        let iteration = Iteration(corpus: self.__corpus, wordToVecParameter: self.__parameter)
        var currentSentence : Sentence = self.__corpus.getSentence(index: iteration.getSentenceIndex())
        let outputs = Vector(size: self.__parameter.getLayerSize(), x: 0.0)
        let outputUpdate = Vector(size: self.__parameter.getLayerSize(), x: 0)
        self.__corpus.shuffleSentences(seed: 1)
        while iteration.getIterationCount() < self.__parameter.getNumberOfIterations(){
            iteration.alphaUpdate()
            let wordIndex = self.__vocabulary.getPosition(word: currentSentence.getWord(index: iteration.getSentencePosition()))
            let currentWord = self.__vocabulary.getWord(index: wordIndex)
            outputs.clear()
            outputUpdate.clear()
            let b = Int.random(in: 0..<self.__parameter.getWindow())
            var cw : Int = 0
            for a in b..<self.__parameter.getWindow() * 2 + 1 - b{
                let c = iteration.getSentencePosition() - self.__parameter.getWindow() + a
                if a != self.__parameter.getWindow() && currentSentence.safeIndex(index: c){
                    let lastWordIndex = self.__vocabulary.getPosition(word: currentSentence.getWord(index: c))
                    outputs.addVector(v: self.__wordVectors.getRowVector(row: lastWordIndex))
                    cw = cw + 1
                }
            }
            if cw > 0{
                outputs.divide(value: Double(cw))
                if self.__parameter.isHierarchicalSoftMax(){
                    for d in 0..<currentWord.getCodeLength(){
                        let l2 = (currentWord as VocabularyWord).getPoint(index: d)
                        var f : Double = outputs.dotProduct(v: self.__wordVectorUpdate.getRowVector(row: l2))
                        if f <= -Double(NeuralNetwork.MAX_EXP) || f >= Double(NeuralNetwork.MAX_EXP){
                            continue
                        } else {
                            f = self.__expTable[Int((f + Double(NeuralNetwork.MAX_EXP)) *
                                                    Double(NeuralNetwork.EXP_TABLE_SIZE / NeuralNetwork.MAX_EXP / 2))]
                        }
                        let g = (1.0 - Double(currentWord.getCode(index: d)) - f) * iteration.getAlpha()
                        outputUpdate.addVector(v: self.__wordVectorUpdate.getRowVector(row: l2).product(value: g))
                        self.__wordVectorUpdate.addRowVector(rowNo: l2, v: outputs.product(value: g))
                    }
                } else {
                    var target : Int
                    var label : Int
                    for d in 0..<self.__parameter.getNegativeSamplingSize() + 1{
                        if d == 0{
                            target = wordIndex
                            label = 1
                        } else {
                            target = self.__vocabulary.getTableValue(index: Int.random(in: 0..<self.__vocabulary.getTableSize()))
                            if target == 0{
                                target = Int.random(in: 0..<self.__vocabulary.size() - 1) + 1
                            }
                            if target == wordIndex{
                                continue
                            }
                            label = 0
                        }
                        let l2 = target
                        let f = outputs.dotProduct(v: self.__wordVectorUpdate.getRowVector(row: l2))
                        let g = self.__calculateG(f: f, alpha: iteration.getAlpha(), label: Double(label))
                        outputUpdate.addVector(v: self.__wordVectorUpdate.getRowVector(row: l2).product(value: g))
                        self.__wordVectorUpdate.addRowVector(rowNo: l2, v: outputs.product(value: g))
                    }
                }
                for a in b..<self.__parameter.getWindow() * 2 + 1 - b{
                    let c = iteration.getSentencePosition() - self.__parameter.getWindow() + a
                    if a != self.__parameter.getWindow() && currentSentence.safeIndex(index: c){
                        let lastWordIndex = self.__vocabulary.getPosition(word: currentSentence.getWord(index: c))
                        self.__wordVectors.addRowVector(rowNo: lastWordIndex, v: outputUpdate)
                    }
                }
            }
            currentSentence = iteration.sentenceUpdate(currentSentence: currentSentence)
        }
    }

    /**
    Main method for training the SkipGram version of Word2Vec algorithm.
    */
    public func __trainSkipGram(){
        let iteration = Iteration(corpus: self.__corpus, wordToVecParameter: self.__parameter)
        var currentSentence : Sentence = self.__corpus.getSentence(index: iteration.getSentenceIndex())
        let outputs = Vector(size: self.__parameter.getLayerSize(), x: 0.0)
        let outputUpdate = Vector(size: self.__parameter.getLayerSize(), x: 0)
        self.__corpus.shuffleSentences(seed: 1)
        while iteration.getIterationCount() < self.__parameter.getNumberOfIterations(){
            iteration.alphaUpdate()
            let wordIndex = self.__vocabulary.getPosition(word: currentSentence.getWord(index: iteration.getSentencePosition()))
            let currentWord = self.__vocabulary.getWord(index: wordIndex)
            outputs.clear()
            outputUpdate.clear()
            let b = Int.random(in: 0..<self.__parameter.getWindow())
            for a in b..<self.__parameter.getWindow() * 2 + 1 - b{
                let c = iteration.getSentencePosition() - self.__parameter.getWindow() + a
                if a != self.__parameter.getWindow() && currentSentence.safeIndex(index: c){
                    let lastWordIndex = self.__vocabulary.getPosition(word: currentSentence.getWord(index: c))
                    let l1 = lastWordIndex
                    outputUpdate.clear()
                    if self.__parameter.isHierarchicalSoftMax(){
                        for d in 0..<currentWord.getCodeLength(){
                            let l2 = currentWord.getPoint(index: d)
                            var f : Double = self.__wordVectors.getRowVector(row: l1).dotProduct(v: self.__wordVectorUpdate.getRowVector(row: l2))
                            if f <= -Double(NeuralNetwork.MAX_EXP) || f >= Double(NeuralNetwork.MAX_EXP){
                                continue
                            } else {
                                f = self.__expTable[Int((f + Double(NeuralNetwork.MAX_EXP)) *
                                                        Double(NeuralNetwork.EXP_TABLE_SIZE / NeuralNetwork.MAX_EXP / 2))]
                            }
                            let g = (1.0 - Double(currentWord.getCode(index: d)) - f) * iteration.getAlpha()
                            outputUpdate.addVector(v: self.__wordVectorUpdate.getRowVector(row: l2).product(value: g))
                            self.__wordVectorUpdate.addRowVector(rowNo: l2, v: self.__wordVectors.getRowVector(row: l1).product(value: g))
                        }
                    } else {
                        var target : Int
                        var label : Int
                        for d in 0..<self.__parameter.getNegativeSamplingSize() + 1{
                            if d == 0{
                                target = wordIndex
                                label = 1
                            } else {
                                target = self.__vocabulary.getTableValue(index: Int.random(in: 0..<self.__vocabulary.getTableSize()))
                                if target == 0{
                                    target = Int.random(in: 0..<self.__vocabulary.size() - 1) + 1
                                }
                                if target == wordIndex{
                                    continue
                                }
                                label = 0
                            }
                            let l2 = target
                            let f = self.__wordVectors.getRowVector(row: l1).dotProduct(v: self.__wordVectorUpdate.getRowVector(row: l2))
                            let g = self.__calculateG(f: Double(f), alpha: iteration.getAlpha(), label: Double(label))
                            outputUpdate.addVector(v: self.__wordVectorUpdate.getRowVector(row: l2).product(value: g))
                            self.__wordVectorUpdate.addRowVector(rowNo: l2, v: self.__wordVectors.getRowVector(row: l1).product(value: g))
                        }
                    }
                    self.__wordVectors.addRowVector(rowNo: l1, v: outputUpdate)
                }
            }
            currentSentence = iteration.sentenceUpdate(currentSentence: currentSentence)
        }
    }

}

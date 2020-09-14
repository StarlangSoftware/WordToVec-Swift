//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 14.09.2020.
//

import Foundation
import Corpus

public class Iteration{
    
    private var __wordCount: Int = 0
    private var __lastWordCount: Int = 0
    private var __wordCountActual: Int = 0
    private var __iterationCount: Int = 0
    private var __sentencePosition: Int = 0
    private var __sentenceIndex: Int = 0
    private var __startingAlpha: Double
    private var __alpha: Double
    private var __corpus: Corpus
    private var __wordToVecParameter: WordToVecParameter

    /**
    Constructor for the Iteration class. Get corpus and parameter as input, sets the corresponding
    parameters.

    - Parameters:
        - corpus : Corpus used to train word vectors using Word2Vec algorithm.
        - wordToVecParameter : Parameters of the Word2Vec algorithm.
    */
    public init(corpus: Corpus, wordToVecParameter: WordToVecParameter){
        self.__corpus = corpus
        self.__wordToVecParameter = wordToVecParameter
        self.__startingAlpha = wordToVecParameter.getAlpha()
        self.__alpha = wordToVecParameter.getAlpha()
    }

    /**
    Accessor for the alpha attribute.

    - Returns: Alpha attribute.
    */
    public func getAlpha() -> Double{
        return self.__alpha
    }

    /**
    Accessor for the iterationCount attribute.

    - Returns: IterationCount attribute.
    */
    public func getIterationCount() -> Int{
        return self.__iterationCount
    }

    /**
    Accessor for the sentenceIndex attribute.

    - Returns: SentenceIndex attribute
    */
    public func getSentenceIndex() -> Int{
        return self.__sentenceIndex
    }

    /**
    Accessor for the sentencePosition attribute.

    - Returns: SentencePosition attribute
    */
    public func getSentencePosition() -> Int{
        return self.__sentencePosition
    }

    /**
    Updates the alpha parameter after 10000 words has been processed.
    */
    public func alphaUpdate(){
        if self.__wordCount - self.__lastWordCount > 10000{
            self.__wordCountActual += self.__wordCount - self.__lastWordCount
            self.__lastWordCount = self.__wordCount
            self.__alpha = self.__startingAlpha * (1.0 - Double(self.__wordCountActual) /
                                                   (Double(self.__wordToVecParameter.getNumberOfIterations()) *
                                                    Double(self.__corpus.numberOfWords()) + 1.0))
            if self.__alpha < self.__startingAlpha * 0.0001{
                self.__alpha = self.__startingAlpha * 0.0001
            }
        }
    }

    /**
    Updates sentencePosition, sentenceIndex (if needed) and returns the current sentence processed. If one sentence
    is finished, the position shows the beginning of the next sentence and sentenceIndex is incremented. If the
    current sentence is the last sentence, the system shuffles the sentences and returns the first sentence.

    PARAMETERS
    ----------
    currentSentence : Sentence
        Current sentence processed.

    RETURNS
    -------
    Sentence
        If current sentence is not changed, currentSentence; if changed the next sentence; if next sentence is
        the last sentence; shuffles the corpus and returns the first sentence.
    */
    public func sentenceUpdate(currentSentence: Sentence) -> Sentence{
        self.__sentencePosition = self.__sentencePosition + 1
        if self.__sentencePosition >= currentSentence.wordCount(){
            self.__wordCount += currentSentence.wordCount()
            self.__sentenceIndex = self.__sentenceIndex + 1
            self.__sentencePosition = 0
            if self.__sentenceIndex == self.__corpus.sentenceCount(){
                self.__iterationCount = self.__iterationCount + 1
                self.__wordCount = 0
                self.__lastWordCount = 0
                self.__sentenceIndex = 0
                self.__corpus.shuffleSentences(seed: 1)
            }
            return self.__corpus.getSentence(index: self.__sentenceIndex)
        }
        return currentSentence
    }
}

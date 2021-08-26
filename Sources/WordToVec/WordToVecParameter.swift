//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 14.09.2020.
//

import Foundation

public class WordToVecParameter{
    
    private var __layerSize: Int = 100
    private var __cbow: Bool = true
    private var __alpha: Double = 0.025
    private var __window: Int = 5
    private var __hierarchicalSoftMax: Bool = false
    private var __negativeSamplingSize: Int = 5
    private var __numberOfIterations: Int = 3
    private var __seed: Int = 1

    /**
    Empty constructor for Word2Vec parameter
    */
    public init(){
    }

    /**
    Accessor for layerSize attribute.

    - Returns: Size of the word vectors.
    */
    public func getLayerSize() -> Int{
        return self.__layerSize
    }

    /**
    Accessor for CBow attribute.

    - Returns: True is CBow will be applied, false otherwise.
    */
    public func isCbow() -> Bool{
        return self.__cbow
    }

    /**
    Accessor for the alpha attribute.

    - Returns: Current learning rate alpha.
    */
    public func getAlpha() -> Double{
        return self.__alpha
    }

    /**
    Accessor for the window size attribute.

    - Returns: Current window size.
    */
    public func getWindow() -> Int{
        return self.__window
    }

    /**
    Accessor for the hierarchicalSoftMax attribute.

    - Returns: If hierarchical softmax will be applied, returns true; false otherwise.
    */
    public func isHierarchicalSoftMax() -> Bool{
        return self.__hierarchicalSoftMax
    }

    /**
    Accessor for the negativeSamplingSize attribute.

    RETURNS
    -------
    Int
        Number of negative samples that will be withdrawn.
    */
    public func getNegativeSamplingSize() -> Int{
        return self.__negativeSamplingSize
    }

    /**
    Accessor for the numberOfIterations attribute.

    - Returns: Number of epochs to train the network.
    */
    public func getNumberOfIterations() -> Int{
        return self.__numberOfIterations
    }

    /**
    Accessor for the seed attribute.

    - Returns: Seed to train the network.
    */
    public func getSeed() -> Int{
        return self.__seed
    }

    /**
    Mutator for the layerSize attribute.

    - Parameter layerSize : New size of the word vectors.
    */
    public func setLayerSize(layerSize: Int){
        self.__layerSize = layerSize
    }

    /**
    Mutator for cBow attribute

    - Parameter cbow : True if CBow applied; false if SkipGram applied.
    */
    public func setCbow(cbow: Bool){
        self.__cbow = cbow
    }

    /**
    Mutator for alpha attribute

    - Parameter alpha : New learning rate.
    */
    public func setAlpha(alpha: Double){
        self.__alpha = alpha
    }

    /**
    Mutator for the window size attribute.

    - Parameter window : New window size.
    */
    public func setWindow(window: Int){
        self.__window = window
    }

    /**
    Mutator for the hierarchicalSoftMax attribute.

    - Parameter hierarchicalSoftMax : True is hierarchical softMax applied; false otherwise.
    */
    public func setHierarchialSoftMax(hierarchicalSoftMax: Bool){
        self.__hierarchicalSoftMax = hierarchicalSoftMax
    }

    /**
    Mutator for the negativeSamplingSize attribute.

    - Parameter negativeSamplingSize : New number of negative instances that will be withdrawn.
    */
    public func setNegativeSamplingSize(negativeSamplingSize: Int){
        self.__negativeSamplingSize = negativeSamplingSize
    }

    /**
    Mutator for the numberOfIterations attribute.

    - Parameter numberOfIterations : New number of iterations.
    */
    public func setNumberOfIterations(numberOfIterations: Int){
        self.__numberOfIterations = numberOfIterations
    }

    /**
    Mutator for the seed attribute.

    - Parameter seed : New seed.
    */
    public func setSeed(seed: Int){
        self.__seed = seed
    }

}

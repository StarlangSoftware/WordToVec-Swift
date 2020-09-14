import XCTest
import Corpus
import Dictionary
@testable import WordToVec

final class NeuralNetworkTest: XCTestCase {
    private var turkish: Corpus = Corpus()
    private var english: Corpus = Corpus()
    
    override func setUp() {
        self.english = Corpus(fileName: "english-similarity-dataset.txt");
        self.turkish = Corpus(fileName: "turkish-similarity-dataset.txt");
    }

    private func train(corpus: Corpus, cBow: Bool) -> VectorizedDictionary{
        let parameter = WordToVecParameter()
        parameter.setCbow(cbow: cBow)
        let neuralNetwork = NeuralNetwork(corpus: corpus, parameter: parameter)
        return neuralNetwork.train()
    }
    
    public func testTrainEnglishCBow(){
        let dictionary = self.train(corpus: self.english, cBow: true)
    }

    public func testTrainEnglishSkipGram(){
        let dictionary = self.train(corpus: self.english, cBow: false)
    }

    public func testTrainTurkishCBow(){
        let dictionary = self.train(corpus: self.turkish, cBow: true)
    }

    public func testTrainTurkishSkipGram(){
        let dictionary = self.train(corpus: self.turkish, cBow: false)
    }

    static var allTests = [
        ("testExample1", testTrainEnglishCBow),
        ("testExample2", testTrainEnglishSkipGram),
        ("testExample3", testTrainTurkishCBow),
        ("testExample4", testTrainTurkishSkipGram),
    ]
}

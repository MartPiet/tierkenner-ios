/**
 TierkennerProtocol.swift
 TierkennerApp
 
 Bachelorthesis "Eine App zur Objekterkennung in Bildern mittels neuronaler Netze,
 trainiert mit dem ILSVRC-Datensatz"
 
 Hochschule Niederrhein
 
 Copyright (c) 2017 Martin Pietrowski
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 **/

import Foundation

/**
 Protocol to make sure every class using Tierkenner.mlmodel is
 able to store classifications the same way.
 */
protocol TierkennerProtocol {
    typealias Classifications = [(identifier: String, confidence: Float)]
    var classifications: Classifications? { get set }
}

extension TierkennerProtocol {
    /**
     Unwraps classifications in a save way.
     
     - Returns: Unwrapped optional array "classifications".
     */
    func unwrappedClassifications() -> Classifications {
        guard let classifications = classifications else {
            fatalError("No classifications available.")
        }
        
        return classifications
    }
}

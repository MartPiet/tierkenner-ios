/**
 DetailedResultsTableViewController.swift
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

import UIKit

class DetailedResultsTableViewController: UITableViewController, TierkennerProtocol {
    var classifications: TierkennerProtocol.Classifications?
    private var predictor: Predictor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .black
        predictor = Predictor()
        
        // Making sure needed values are set.
        guard classifications != nil else {
            fatalError("No predictions being set.")
        }
    }

    /*
     Sets predictions for this class. Have to be called before this view show up.
     
     - Parameter predictions: List with labels and their probability.
     */
    func set(classifications: TierkennerProtocol.Classifications) {
        self.classifications = classifications
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     Number of rows are the number of cellContent entries.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unwrappedClassifications().count
    }
    
    /**
     Creates a predictionCell and sets it by given data.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath)

        guard let textLabel = cell.textLabel else {
            fatalError("TableCell has no textLabel.")
        }
        
        guard let detailTextLabel = cell.detailTextLabel else {
            fatalError("TableCell has no detailTextLabel.")
        }
        
        var probabilityForRow = unwrappedClassifications()[indexPath.row].confidence * 100
        probabilityForRow = probabilityForRow.rounded(toPlaces: 2)
        
        if !isProbabilityHighEnough(probabilty: probabilityForRow) {
            probabilityForRow = 0
        }
        
        textLabel.text = predictor.getLabel(key: unwrappedClassifications()[indexPath.row].identifier)
        detailTextLabel.text = String(describing: probabilityForRow) + " %"
        
        return cell
    }
    
    private func isProbabilityHighEnough(probabilty: Float) -> Bool {
        if probabilty < 0.001 {
            return false
        }
        
        return true
    }
}

/**
 Extension of datatype Float, whichs is only used in this class.
 */
extension Float {
    // Rounds the float to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

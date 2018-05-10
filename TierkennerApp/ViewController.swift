/**
ViewController.swift
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
import CoreImage

/**
 Functionality of the user interface, in this case an UIViewController.
 
 - UIImagePickerControllerDelegate: For taking pictures with camera or taking photos from gallery.
 - UINavigationControllerDelegate: Needed from UIImagepickerControllerDelegate.
 - UITableViewDelegate: For displaying and controlling the behaviour of table cells.
 - UITableViewDataSource: For handling data with the table view.
 
 Contains an ImageView for the selected picture, a text consisting of labels for prediction with
 probabilitiy and two buttons for wether taking or selecting a picture. In addition there will
 show up a button in top left position to see all possible classifications with a probability.
 
 Also handles taking/selecting picture dialogue.
 */
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TierkennerProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var confidenceLabel: UILabel!
    @IBOutlet private weak var classificationLabel: UILabel!
    @IBOutlet private weak var labelStack: UIStackView!
    @IBOutlet private weak var manualTextView: UITextView!
    private var predictor: Predictor!
    private var picker: UIImagePickerController!
    var classifications: Classifications?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        picker = UIImagePickerController()
        picker.delegate = self

        // To remove "Details"-Button on top right position.
        self.navigationItem.rightBarButtonItem = nil
        
        predictor = Predictor()
        classifications = TierkennerProtocol.Classifications()
    }
}

/**
 Extension with UI functions.
 */
extension ViewController {
    /**
     Updates labels for a given state.
     
     Checks if there are predictions, fills the values into the label texts
     and shows all labels.
     
     States:
         - No Picture selected
         - No object in Picture classified
         - Object in Picture classified
     */
    private func updateLabels() {
        let confidenceLabelFirstPart = "Auf dem Bild ist zu "
        var confidenceLabelLastPart = "% ein"
        let confidenceLabelErrorText = "Auf dem Bild ist"
        var confidenceLabelClassificationText = "Nichts"
        
        // If there is a prediction
        if let prediction = unwrappedClassifications().first {
            let classification = predictor.getLabel(key: prediction.identifier)
            
            // Checks last letter for an 'e' for correct grammar ('ein' and 'eine')
            let lastCharacterOfClassification = classification[classification.index(classification.index(of: classification.last!)!, offsetBy: -2)]
            if lastCharacterOfClassification == "e" {
                confidenceLabelLastPart.append("e")
            }
            
            // Constructs full text
            confidenceLabel.text = confidenceLabelFirstPart + String(Int(prediction.confidence * 100)) + confidenceLabelLastPart
            confidenceLabelClassificationText = classification
        // If there is no prediction
        } else {
            confidenceLabel.text = confidenceLabelErrorText
        }
        
        classificationLabel.text = confidenceLabelClassificationText
        
        // Shows all needed labels (confidenceLabel, classificationLabel is grouped in a stack)
        labelStack.isHidden = false
    }
    
    /**
     Creates and shows a BarButtonItem in the navigation bar.
    */
    func createRightBarButtonItem() -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(title: "Details", style: .plain, target: self, action: #selector(showDetailedResultsTableViewController))
        barButtonItem.tintColor = .black
        
        return barButtonItem
    }
    
    /**
     Creates and shows a new view with all predictions for an image.
     */
    @objc private func showDetailedResultsTableViewController() {
        guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "detailedResultsTableViewController") as? DetailedResultsTableViewController else {
            print("Could not instantiate view controller with identifier of type SecondViewController")
            return
        }
        vc.set(classifications: unwrappedClassifications())
        
        self.navigationController?.pushViewController(vc, animated:true)
    }
}

/**
 For Imagepicker functions.
 */
extension ViewController {
    /**
     Is called when shooted picture was confirmed or picture was selected from album.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Close ImagePicker view.
        
        picker.dismiss(animated: true, completion: nil)
                
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            processImage(image: img)
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            processImage(image: img)
        } else {
            print("Something went wrong")
        }
    }
    
    /**
     Uses given image for classification.
     
     Also sets new backgroundimage for the view. After classification,
     the labels will be updated. Shows up "Detail" Button on top right
     position. During this process an activity indicator will be
     shown.
     
     - Parameter image: UIImage to classify.
     */
    func processImage(image: UIImage) {
        activityIndicator.startAnimating()
        
        self.manualTextView.isHidden = true
        
        DispatchQueue.main.async {
            self.backgroundImageView.image = self.createBackgroundImage(image: image)
            self.imageView.image = image
            
            self.classifications = self.predictor.predict(image: image)
            
            self.updateLabels()
            self.navigationItem.rightBarButtonItem = self.createRightBarButtonItem()
            self.activityIndicator.stopAnimating()
        }
    }
    
    /*
     Creates a background image by using CIFilters.
     
     Background image will be first blurred and then set to brighter colors.
     To use filters, UIImage needs to be converted to CIImage. After using
     filters, CIImage will be converted back to UIImage.
     
     - Parameter image: Image to set as background image.
     
     - Returns: Image prepared to use as background image.
          */
    private func createBackgroundImage(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let filters = [
            "CIGaussianBlur":
                (valueKey: kCIInputRadiusKey, value: 10.0),
            "CIColorControls":
                (valueKey: kCIInputBrightnessKey, value: 0.1)
        ]

        guard var currentImage = CIImage(image: image) else {
            print("Convert from UIImage to CIImage failed.")
            return image
        }
        
        for filter in filters {
            currentImage = filterImage(image: currentImage, filter: filter.key, valueKey: filter.value.valueKey, value: filter.value.value)
        }
        
        guard let cgImage = context.createCGImage(currentImage, from: currentImage.extent) else {
            print("Convert from CIImage to CGImage failed.")
            return image
        }
        
        let processedImage = UIImage(cgImage: cgImage)
        
        return processedImage
    }
    
    /*
     Uses CIFilter with given parameters.
     
     Creates filter and sets given filter parameters.
     
     - Parameter image: Image to use filter on.
     - Parameter filter: Name of CIFilter.
     - Parameter valueKey: Name of value.
     - Parameter value: Value for filter.
     
     - Returns: Filtered image.
     */
    private func filterImage(image: CIImage, filter: String, valueKey: String, value: Double) -> CIImage {
        guard let currentFilter = CIFilter(name: filter) else {
            print("Filter not available.")
            return image
        }
        
        currentFilter.setValue(image, forKey: kCIInputImageKey)
        currentFilter.setValue(value, forKey: valueKey)
        
        guard let output = currentFilter.outputImage else {
            print("No output image from currentFilter available.")
            return image
        }
        
        return output
    }
    
    /*
     Is called when no camera is available.
     */
    func noCamera(){
        let alertVC = UIAlertController(
            title: "Keine Kamera",
            message: "Dieses Gerät verfügt über keine Kamera. Bitte wähle ein Foto aus deiner Fotogalerie aus.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    /**
     Opens library to select a picture.
     */
    @IBAction func photoFromLibrary(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
    }
    
    /**
     Checks if camera is available, take picture
     */
    @IBAction func shootPhoto(_ sender: Any) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    /**
     Dismisses view if imagePicker is being cancelled.
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


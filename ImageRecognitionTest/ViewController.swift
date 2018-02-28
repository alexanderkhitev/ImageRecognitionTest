//
//  ViewController.swift
//  ImageRecognitionTest
//
//  Created by Alexander Khitev on 2/28/18.
//  Copyright © 2018 Alexander Khitev. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    
    // MARK: - ML
    
    private let mobileNet = MobileNet()

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    // MARK: - IBActions
    
    @IBAction private func presentPicker(_ button: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let number = Int(arc4random_uniform(6))
        if number % 2 == 0 {
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - ML functions
    
    private func getImageInfo(_ image: UIImage) {
        guard let model = try? VNCoreMLModel(for: mobileNet.model) else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: handleRequest)
        request.imageCropAndScaleOption = .centerCrop
        
        guard let cgImage = image.cgImage else { return }
        guard let cgImageOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgImageOrientation)
            do {
                try handler.perform([request])
            } catch {
                debugPrint(error.localizedDescription)
            }
        }

    }

    private func handleRequest(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let results = request.results else {
                self?.resultLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            guard let classifications = results as? [VNClassificationObservation] else { return }
            guard let topClassification = classifications.first else { return }
            self?.resultLabel.text = topClassification.identifier
        }
    }

}

// MARK: - UIImagePickerController Delegate

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let tempImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageView.image = tempImage
        getImageInfo(tempImage)
    }
    
}

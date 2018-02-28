//
//  ViewController.swift
//  ImageRecognitionTest
//
//  Created by Alexander Khitev on 2/28/18.
//  Copyright © 2018 Alexander Khitev. All rights reserved.
//

import UIKit

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
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - ML functions
    
    private func getImageInfo(_ image: UIImage) {
        guard let pixelBuffer = ImageToPixelBufferConverter.convertToPixelBuffer(image: image) else { return }
        do {
            let result = try mobileNet.prediction(image: pixelBuffer)
            resultLabel.text = result.classLabel
        } catch {
            debugPrint(error.localizedDescription)
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

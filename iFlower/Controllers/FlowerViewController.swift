//
//  ViewController.swift
//  iFlower
//
//  Created by Victoria Boichenko on 23.08.2020.
//  Copyright © 2020 Victoria Boichenko. All rights reserved.
//

import UIKit
import CoreML
import Vision
//import Alamofire
//import SwiftyJSON

class FlowerViewController: UIViewController {
    
    @IBOutlet weak var flowerView: UIImageView!
    @IBOutlet weak var flowerDescription: UILabel!
    
    let flowerImagePicker = UIImagePickerController()

    
    var flowerManager = FlowerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowerImagePicker.delegate = self
               flowerImagePicker.allowsEditing = true
        flowerImagePicker.sourceType = .camera
        flowerManager.delegate = self
//        flowerManager.fetchData(flowerName: "barberton daisy")
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(flowerImagePicker, animated: true, completion: nil)
    }
    
}

extension FlowerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        flowerImagePicker.dismiss(animated: true, completion: nil)
       
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            flowerView.image = userPickedImage
//            flowerView.image = UIImage(named: "smth")
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could'n convert image into CIImage")
            }
            detect(from: ciimage)
        }
    }
    
    func detect(from ciimage: CIImage){
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else{
            fatalError("Failed to load ML model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed to get results from request")
            }
            if let firstResult = results.first {
                let text = String(format: "%.2f %@", firstResult.confidence, firstResult.identifier)
                self.navigationItem.title = text.capitalized
                self.flowerManager.fetchData(flowerName: firstResult.identifier)
                print(text)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciimage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

extension FlowerViewController: FlowerManagerDelegate {
    func didUpdateFlowerData(model: FlowerModel) {
        DispatchQueue.main.async {
            self.flowerDescription.text = model.description
        }
    }
    
    func didFailWith(_ error: String) {
        let alert = UIAlertController(title: "Problems", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
//
//    func fetchData(flowerName: String){
//        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
//
//         let parameters : [String:String] = [
//         "format" : "json",
//         "action" : "query",
//         "prop" : "extracts",
//         "exintro" : "",
//         "explaintext" : "",
//         "titles" : flowerName,
//         "indexpageids" : "",
//         "redirects" : "1",
//         ]
//
//        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
//            if response.result.isSuccess {
//                print("Response is successful \(response)")
//            }
//        }
//    }




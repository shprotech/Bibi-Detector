//
//  BibiPredicator.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/15/20.
//

import Combine
import SwiftUI
import Vision

class BibiPredicator: ObservableObject {
    typealias PredicationResult = Result<[Prediction], BibiPredicatorErrors>
    
    /// The predication of the given image (if any).
    @Published private(set) var prediction: PredicationResult?
    
    private var mainThreadPrediction: PredicationResult? {
        get {
            return prediction
        }
        
        set {
            DispatchQueue.main.async { [weak self] in
                self?.prediction = newValue
            }
        }
    }
    
    private var image: UIImage
    
    /**
     Create a new BibiPredicator with the given image.
     - Parameter image: The image to create the predication from.
     */
    init(image: UIImage) {
        self.image = image
        
        self.predicate()
    }
    
    /**
     Create the predication of the given image.
     */
    private func predicate() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.detectFaces()
        }
    }
    
    /**
     Detect all the faces in the image and create the prediction of each face.
     */
    private func detectFaces() {
        guard let cgImage = image.cgImage else {
            self.mainThreadPrediction = .failure(.invalidImage)
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let detectFacesRequest = VNDetectFaceRectanglesRequest(completionHandler: predicateFaces(request:error:))
        
        do {
            try handler.perform([detectFacesRequest])
        } catch {
            self.mainThreadPrediction = .failure(.other(error: error))
        }
    }
    
    /**
     Create the predication for each face.
     - Parameter request: The results of the vision request.
     - Parameter error: The errors of the request.
     */
    private func predicateFaces(request: VNRequest, error: Error?) {
        if let error = error {
            mainThreadPrediction = .failure(.other(error: error))
            return
        }
        
        guard let results = request.results as? [VNFaceObservation] else {
            mainThreadPrediction = .failure(.noFaces)
            return
        }
        
        if results.count == 0 {
            mainThreadPrediction = .failure(.noFaces)
            return
        }
        
        self.createPredictions(for: results.map { (result) in
            result.boundingBox
        })
    }
    
    // swiftlint:disable identifier_name
    /**
     Convert the rect of a face to the dimentions of the image.
     - Parameter face: The rect of the face in the VNFaceObservation bounding box.
     - Returns: The new rect in the dimentions of the original image.
     */
    private func convert(face rect: CGRect) throws -> CGRect {
        guard let image = self.image.cgImage else {
           throw BibiPredicatorErrors.invalidImage
        }
        
        let width = rect.width * CGFloat(image.width)
        let height = rect.height * CGFloat(image.height)
        let x = rect.origin.x * CGFloat(image.width)
        let y = (1 - rect.origin.y) * CGFloat(image.height) - width
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    // swiftlint:enable identifier_name
    
    /**
     Create prediction for each face using the given image.
     - Parameter faces: The rects of each face in the image.
     */
    private func createPredictions(for faces: [CGRect]) {
        guard let cgImage = self.image.cgImage else {
            mainThreadPrediction = .failure(.invalidImage)
            return
        }
        var predictions = [Prediction]()
        
        for face in faces {
            do {
                let scaledFace = try convert(face: face)
                
                guard let croppedImage = cgImage.cropping(to: scaledFace) else {
                    mainThreadPrediction = .failure(.invalidImage)
                    return
                }
                
                var prediction = try predicate(image: croppedImage)
                prediction.box = face
                predictions.append(prediction)
            } catch {
                mainThreadPrediction = .failure(.other(error: error))
            }
        }
        
        mainThreadPrediction = .success(predictions)
    }
    
    /**
     Create a prediction of a single image.
     - Parameter image: The image to use for the prediction.
     - Returns: The result of the prediction.
     */
    private func predicate(image: CGImage) throws -> Prediction {
        let model = try BibiClassifier(configuration: .init())
        let input = try BibiClassifierInput(imageWith: image)
        let output = try model.prediction(input: input)
        return Prediction(bibi: output.classLabel == "bibi",
                          confidence: output.classLabelProbs[output.classLabel] ?? 0,
                          box: CGRect(),
                          image: UIImage(cgImage: image))
    }
}

enum BibiPredicatorErrors: LocalizedError {
    case invalidImage
    case failedToCreateBuffer
    case noFaces
    case invalidFacesResults
    case other(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Given invalid image."
        case .failedToCreateBuffer:
            return "Failed to create buffer from image."
        case .noFaces:
            return "There are no faces in the image."
        case .invalidFacesResults:
            return "There was an error while getting the faces in the image."
        case .other(let error):
            return "There was another error while creating prediction: \(error.localizedDescription)"
        }
    }
}

/**
 A struct that represents a prediction result.
 */
struct Prediction: Identifiable {
    /// If true - Bibi is in the photo.
    var bibi: Bool
    /// The confidence of the prediction (0-1).
    var confidence: Double
    /// The rect of the face (0-1 from bottom left).
    var box: CGRect
    /// The tested image.
    var image: UIImage
    /// The id of the prediction.
    // swiftlint:disable identifier_name
    var id = UUID()
}

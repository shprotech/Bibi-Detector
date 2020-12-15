//
//  ImageDetectionView.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/15/20.
//

import SwiftUI

struct ImageDetectionView: View {
    var image: UIImage
    
    @ObservedObject private var predicator: BibiPredicator
    
    init(image: UIImage) {
        self.image = image
        _predicator = ObservedObject(initialValue: BibiPredicator(image: image))
    }
    
    private let imageSize: CGFloat = 150
    
    var body: some View {
        Group {
            if let prediction = predicator.prediction {
                switch prediction {
                case .success(let predictions):
                    ScrollView {
                        PredictionTopImageView(image: image, predicator: predicator)
                        ForEach(predictions) { result in
                            HStack {
                                if result.bibi {
                                    Text("Bibi for \(result.confidence)")
                                } else {
                                    Text("Not Bibi for \(result.confidence)")
                                }
                                
                                Spacer()
                                Image(uiImage: result.image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .frame(maxWidth: imageSize, maxHeight: imageSize)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                case .failure(let error):
                    Text("There was an error while predicating: \(error.localizedDescription)")
                        .padding()
                }
            } else {
                Text("Predicting...")
                    .padding()
            }
        }
    }
    
    /**
     Convert the rect of a face to the dimentions of the image.
     - Parameter face: The rect of the face in the VNFaceObservation bounding box.
     - Returns: The new rect in the dimentions of the original image.
     */
    private func convert(face rect: CGRect, with box: CGRect) -> CGRect {
        let width = rect.width * box.width
        let height = rect.height * box.height
        let x = rect.origin.x * box.width
        let y = rect.origin.y * box.height - height * 2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

struct ImageDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetectionView(image: UIImage(named: "bibi")!)
    }
}

//
//  PredictionTopImageView.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/15/20.
//

import SwiftUI
import CoreGraphics

struct PredictionTopImageView: View {
    var image: UIImage
    var predicator: BibiPredicator
    
    private let faceRectRadius: CGFloat = 5
    private let faceRectLineWidth: CGFloat = 2
    
    var body: some View {
        ZStack {
            switch predicator.prediction {
            case .success(let predictions):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .id("top_image")
                
                ForEach(predictions) { prediction in
                    GeometryReader { geo in
                        if prediction.bibi {
                            RoundedRectangle(cornerRadius: faceRectRadius, style: .continuous)
                                .path(in: rect(for: prediction.box, in: geo.frame(in: .named("top_image"))))
                                .stroke(Color.green, lineWidth: faceRectLineWidth)
                        } else {
                            RoundedRectangle(cornerRadius: faceRectRadius, style: .continuous)
                                .path(in: rect(for: prediction.box, in: geo.frame(in: .named("top_image"))))
                                .stroke(Color.red, lineWidth: faceRectLineWidth)
                        }
                    }
                }
            case .failure, .none:
                EmptyView()
            }
        }
    }
    
    /**
     Get the rect of the face in the geometry of the image.
     - Parameter prediction: The rect of the face in the prediction.
     - Parameter geo: The geometry of the image.
     - Returns: The rect of the face in the geometry of the image.
     */
    func rect(for prediction: CGRect, in geo: CGRect) -> CGRect {
        let height = prediction.height * geo.height
        return CGRect(x: prediction.minX * geo.width,
                      y: ((1 - prediction.minY) * geo.height) - height,
                      width: prediction.width * geo.width,
                      height: height)
    }
}

struct PredictionTopImageView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionTopImageView(image: UIImage(named: "bibi")!,
                               predicator: BibiPredicator(image: UIImage(named: "bibi")!))
    }
}

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
    @ObservedObject var coordinator: SnapshotCoordinator
    
    private let faceRectRadius: CGFloat = 5
    private let faceRectLineWidth: CGFloat = 2
    private let confidenceOffset: CGFloat = 10
    private let topImageId = "top_image"
    
    var body: some View {
        ZStack {
            switch predicator.prediction {
            case .success(let predictions):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .id(topImageId)
                
                ForEach(predictions) { prediction in
                    GeometryReader { geo in
                        ZStack {
                            if prediction.bibi {
                                RoundedRectangle(cornerRadius: faceRectRadius, style: .continuous)
                                    .path(in: rect(for: prediction.box,
                                                   in: geo.frame(in: .named(topImageId))))
                                    .stroke(Color.green, lineWidth: faceRectLineWidth)
                            } else {
                                RoundedRectangle(cornerRadius: faceRectRadius, style: .continuous)
                                    .path(in: rect(for: prediction.box,
                                                   in: geo.frame(in: .named(topImageId))))
                                    .stroke(Color.red, lineWidth: faceRectLineWidth)
                            }
                            Text(String(format: "%.2f%%", prediction.bibiConfidence * 100))
                                .position(
                                    confidencePosition(for: prediction.box, in: geo.frame(in: .named(topImageId)))
                                )
                                .padding(0)
                                .shadow(radius: 2)
                        }
                    }
                }
            case .failure, .none:
                EmptyView()
            }
        }
        .onReceive(coordinator.$shouldTakeSnapshot) { shouldTake in
            if shouldTake {
                coordinator.clear()
                print("Taking snapshot.")
                let snapshot = self.snapshot()
                print("Took: \(snapshot)")
                coordinator.set(snapshot: snapshot)
            } else {
                print("Not taking.")
            }
        }
    }
    
    /**
     Get the position of the confidence label.
     - Parameter prediction: The rect of the face in the prediction.
     - Parameter geo: The geometry of the image.
     - Returns: The position for the confidence label.
     */
    private func confidencePosition(for prediction: CGRect, in geo: CGRect) -> CGPoint {
        let height = prediction.height * geo.height
        return CGPoint(
            x: prediction.midX * geo.width,
            y: ((1 - prediction.minY) * geo.height) - height - confidenceOffset
        )
    }
    
    /**
     Get the rect of the face in the geometry of the image.
     - Parameter prediction: The rect of the face in the prediction.
     - Parameter geo: The geometry of the image.
     - Returns: The rect of the face in the geometry of the image.
     */
    private func rect(for prediction: CGRect, in geo: CGRect) -> CGRect {
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
                               predicator: BibiPredicator(image: UIImage(named: "bibi")!), coordinator: SnapshotCoordinator())
    }
}

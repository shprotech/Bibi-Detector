//
//  PredictionTopImageView.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/15/20.
//

import SwiftUI

struct PredictionTopImageView: View {
    var image: UIImage
    var predicator: BibiPredicator
    
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
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .path(in: rect(for: prediction.box, in: geo.frame(in: .named("top_image"))))
                                .stroke(Color.green, lineWidth: 2)
                        } else {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .path(in: rect(for: prediction.box, in: geo.frame(in: .named("top_image"))))
                                .stroke(Color.red, lineWidth: 2)
                        }
                    }
                }
            case .failure(_), .none:
                EmptyView()
            }
        }
    }
    
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
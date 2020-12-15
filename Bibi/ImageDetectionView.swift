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
            switch predicator.prediction {
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
            case .none:
                Text("Predicting...")
                    .padding()
            }
        }
    }
}

struct ImageDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetectionView(image: UIImage(named: "bibi")!)
    }
}

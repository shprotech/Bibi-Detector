//
//  ImageDetectionView.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/15/20.
//

import SwiftUI

struct ImageDetectionView: View {
    var image: UIImage
    
    let shareButtonSize: CGFloat = 20
    
    @ObservedObject private var predicator: BibiPredicator
    @ObservedObject private var coordinator: SnapshotCoordinator
    
    init(image: UIImage) {
        self.image = image
        _predicator = ObservedObject(initialValue: BibiPredicator(image: image))
        _coordinator = ObservedObject(initialValue: SnapshotCoordinator())
    }
    
    private let imageSize: CGFloat = 150
    
    var body: some View {
        Group {
            switch predicator.prediction {
            case .success(let predictions):
                ScrollView {
                    PredictionTopImageView(image: image, predicator: predicator, coordinator: coordinator)
                    ForEach(predictions) { result in
                        HStack {
                            Text(formatted(prediction: result))
                            
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
        .navigationBarItems(
            trailing:
                Button {
                    share()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: shareButtonSize))
                }
        )
        .onReceive(coordinator.$snapshot) { snapshot in
            if let snapshot = snapshot {
                showShareSheet(for: snapshot)
            }
        }
    }
    
    /**
     Start the share process.
     */
    func share() {
        coordinator.takeSnapshot()
    }
    
    /**
     Show the share sheet for the given image.
     - Parameter image: The image to share.
     */
    func showShareSheet(for image: UIImage) {
        let activityView = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityView, animated: true, completion: nil)
    }
    
    func formatted(prediction: Prediction) -> String {
        let confidence = String(format: "%.2f", prediction.confidence * 100)
        return "\(prediction.bibi ? "" : "Not ")Bibi for \(confidence)%"
    }
}

struct ImageDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetectionView(image: UIImage(named: "bibi")!)
    }
}

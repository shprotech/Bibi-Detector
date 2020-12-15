//
//  ContentView.swift
//  Bibi
//
//  Created by Shahar Melamed on 12/14/20.
//

import SwiftUI
import ImagePickerView

struct ContentView: View {
    @ObservedObject var predicator = BibiPredicator(image: UIImage(named: "bibi")!)
    
    @State private var image: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white)
                        )
                        .padding(10)
                    NavigationLink("Detect!", destination: ImageDetectionView(image: image))
                        .padding(.vertical)
                }
                Button {
                    showImagePicker = true
                } label: {
                    Text("Select Image")
                }
            }
            .navigationTitle("Select Image")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary) { (image) in
                self.image = image
                self.showImagePicker = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

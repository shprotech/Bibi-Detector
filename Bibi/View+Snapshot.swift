//
//  View+Snapshot.swift
//  Bibi
//
//  Created by Shahar Melamed on 4/9/21.
//

import SwiftUI

extension View {
    /**
     Get a snapshot of the view.
     - Returns: The snapshot of the view.
     */
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view  = controller.view
        let targetSize = controller.view.intrinsicContentSize
        
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

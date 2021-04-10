//
//  SnapshotCoordinator.swift
//  Bibi
//
//  Created by Shahar Melamed on 4/10/21.
//

import Combine
import UIKit

class SnapshotCoordinator: ObservableObject {
    /// If changes to true - take a snapshot.
    @Published private(set) var shouldTakeSnapshot = false
    
    /// The current snapshot.
    @Published private(set) var snapshot: UIImage?
    
    /**
     Tell the observers to take a snapshot.
     */
    func takeSnapshot() {
        shouldTakeSnapshot = true
    }
    
    /**
     Clear the snapshot flag.
     */
    func clear() {
        shouldTakeSnapshot = false
    }
    
    /**
     Set the current snapshot image.
     */
    func set(snapshot: UIImage) {
        self.snapshot = snapshot
    }
}

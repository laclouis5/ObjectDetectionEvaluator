//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == BoundingBox {
    // MARK: - Computed Properties
    var labels: Set<String> {
        Set(map(\.label))
    }

    var imageNames: Set<String> {
        Set(map(\.name))
    }
    
    func detections() -> [BoundingBox] {
        filter { $0.detectionMode == .detection }
    }
    
    func groundTruths() -> [BoundingBox] {
        filter { $0.detectionMode == .groundTruth }
    }
    
    var boxesByImageName: [String: [BoundingBox]] {
        reduce(into: [:]) { (dict, box) in
            dict[box.name, default: []].append(box)
        }
    }

    var boxesByLabel: [String: [BoundingBox]] {
        reduce(into: [:]) { (dict, box) in
            dict[box.label, default: []].append(box)
        }
    }

    var stats: String {
        var description = "Global Stats\n".uppercased()
        description += "Ground Truth Count: \(detections().count.decimal())\n"
        description += "Detection Count:    \(groundTruths().count.decimal())\n"
        description += "Number of labels:   \(groundTruths().labels.count.decimal())\n\n"
        description += labelStats

        return description
    }

    var labelStats: String {
        boxesByLabel.keys.sorted().reduce(into: "") { (description, label) in
            description += label.uppercased() + "\n"
            description += "  Images:      \(boxesByLabel[label]!.imageNames.count.decimal())\n"
            description += "  Annotations: \(boxesByLabel[label]!.count.decimal())\n\n"
        }
    }

    // MARK: - Methods
    mutating func mapLabels(with labels: [String: String]) {
        guard Set(labels.keys) == Set(self.labels) else {
            print("Error: new label keys must match old labels")
            print("Old Labels: \(self.labels)")
            print("Given labels: \(labels.keys)")
            return
        }
        self = map {
            BoundingBox(name: $0.name, label: labels[$0.label]!, box: $0.box, coordSystem: $0.coordSystem, confidence: $0.confidence, imgSize: $0.imgSize)
        }
    }
}

//
//  UIView+Radius.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/30/24.
//

import Foundation
import UIKit

extension UIView {
    func setCornerRadiusForTopCorners(radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath

        layer.mask = maskLayer
    }
}

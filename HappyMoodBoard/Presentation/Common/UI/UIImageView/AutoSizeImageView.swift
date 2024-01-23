//
//  AutoSizeImageView.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/23.
//

import UIKit

class AutoSizeImageView: UIImageView {
    
    var maxSize: CGFloat
    
    init(maxSize: CGFloat) {
        self.maxSize = maxSize
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSize() -> CGSize {
        guard let image = image else { return .zero }
        
        if image.size.width == image.size.height { return CGSize(width: maxSize, height: maxSize) }
        
        if image.size.width > image.size.height {
            let widthRatio = maxSize / image.size.width
            let scaledHeight = image.size.height * widthRatio
            return CGSize(width: maxSize, height: scaledHeight)
        }
        
        let heightRatio = maxSize / image.size.height
        let scaledWidth = image.size.width * heightRatio
        return CGSize(width: scaledWidth, height: maxSize)
    }
    
}

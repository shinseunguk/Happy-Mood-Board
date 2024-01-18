//
//  UIImage+Utils.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/17.
//

import UIKit

extension UIImage {
    func withImage(_ secondImage: UIImage) -> UIImage? {
        let newImageWidth  = max(size.width, secondImage.size.width)
        let newImageHeight = max(size.height, secondImage.size.height)
        let newImageSize = CGSize(width: newImageWidth, height: newImageHeight)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        draw(at: CGPoint(x: firstImageDrawX, y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}

//
//  PaddingLabel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/02/02.
//

import UIKit

class PaddingLabel: UILabel {
    
    var inset: UIEdgeInsets

    init(inset: UIEdgeInsets = .init()) {
        self.inset = inset
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += inset.top + inset.bottom
        contentSize.width += inset.left + inset.right
        return contentSize
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (inset.left + inset.right)
        }
    }
    
}

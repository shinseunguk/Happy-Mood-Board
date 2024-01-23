//
//  CustomTableView.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/22/24.
//

import Foundation
import UIKit

class CustomTableView: UITableView {

    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }

}

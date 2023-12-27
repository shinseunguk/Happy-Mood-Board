//
//  ViewAttributes.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/01.
//

import Foundation

public protocol ViewAttributes {
    // Optional Functions
    func setupNavigationBar()
    
    // Required Functions
    func setupSubviews()
    func setupLayouts()
    func setupBindings()
}

public extension ViewAttributes {
    func setupNavigationBar() {}
}

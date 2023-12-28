//
//  ViewModel.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2023/12/01.
//

import Foundation

public protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

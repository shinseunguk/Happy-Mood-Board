//
//  EditTagSection.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/19.
//

import Foundation

import RxDataSources

struct EditTagSection {
    var items: [Item]
}

extension EditTagSection: AnimatableSectionModelType {
    typealias Item = Tag
    typealias Identity = Int
    
    init(original: EditTagSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    var identity: Int { 0 }
}

extension Tag: IdentifiableType {
    var identity: Int { id ?? 0 }
}

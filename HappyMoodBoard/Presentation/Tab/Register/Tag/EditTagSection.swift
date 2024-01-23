//
//  EditTagSection.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/19.
//

import Foundation

import RxDataSources

struct EditTagSection {
    var header: String
    var items: [Item]
}

extension EditTagSection: AnimatableSectionModelType {
    typealias Item = Tag
    
    var identity: String { header }
    
    init(original: EditTagSection, items: [Item]) {
        self = original
        self.items = items
    }
}

extension Tag: IdentifiableType {
    var identity: Int { id }
}

//
//  TagListSection.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/24.
//

import Foundation

import RxDataSources

// MARK: - Item

enum TagListItem {
    case tag(Tag)
    case add
}

extension TagListItem: IdentifiableType, Equatable {
    var identity: Int {
        switch self {
        case .add:
            return -1
        case .tag(let tag):
            return tag.id
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identity == rhs.identity
    }
}

// MARK: - Section

struct TagListSection {
    var items: [Item]
}

extension TagListSection: AnimatableSectionModelType {
    typealias Item = TagListItem
    typealias Identity = Int
    
    init(original: TagListSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    var identity: Int { 0 }
}

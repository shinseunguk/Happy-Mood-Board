//
//  PostService.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import UIKit

import RxSwift

struct UserPreferences {
    private init () {}

    static let tag = "Tag"
}

class PreferencesService {

    static let shared = PreferencesService()
    
    private init() { }
    
    func setTag(_ tag: Tag) {
        let defaults = UserDefaults.standard
        let data = try? JSONEncoder().encode(tag)
        defaults.set(data, forKey: UserPreferences.tag)
    }

    /// removes the onBoarded preference
    func removeTag() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserPreferences.tag)
    }

    func tag() -> Tag? {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: UserPreferences.tag) else { return nil }
        return try? JSONDecoder().decode(Tag.self, from: data)
    }
    
}

extension PreferencesService: ReactiveCompatible {}

extension Reactive where Base: PreferencesService {
    var tag: Observable<Tag?> {
        return UserDefaults.standard
            .rx
            .observe(Data.self, UserPreferences.tag)
            .map { data in
                guard let data = data else { return nil }
                return try? JSONDecoder().decode(Tag.self, from: data)
            }
    }
}

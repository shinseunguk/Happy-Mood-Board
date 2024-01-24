//
//  PreferencesService.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/18.
//

import UIKit

import RxSwift

struct UserPreferences {
    private init () {}
    
    static let tag = "Tag"
    static let memberId = "memberId"
}

class PreferencesService {
    
    static let shared = PreferencesService()
    
    let defaults: UserDefaults = .standard
    
    private init() { }
    
    func removeTag() {
        defaults.removeObject(forKey: UserPreferences.tag)
    }
    
    var tag: Tag? {
        get {
            guard let data = defaults.data(forKey: UserPreferences.tag) else { return nil }
            return try? JSONDecoder().decode(Tag.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: UserPreferences.tag)
        }
    }
    
    var memberId: Int? {
        get { defaults.integer(forKey: UserPreferences.memberId) }
        set { defaults.setValue(memberId, forKey: UserPreferences.memberId) }
    }
    
}

extension PreferencesService: ReactiveCompatible { }

extension Reactive where Base: PreferencesService {
    var tag: Observable<Tag?> {
        return base.defaults
            .rx
            .observe(Data.self, UserPreferences.tag)
            .map { data in
                guard let data = data else { return nil }
                return try? JSONDecoder().decode(Tag.self, from: data)
            }
    }
}

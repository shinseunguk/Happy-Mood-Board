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
    
    static let memberId = "memberId"
}

class PreferencesService {
    
    static let shared = PreferencesService()
    
    let defaults: UserDefaults = .standard
    
    private init() { }
    
    var memberId: Int? {
        get { defaults.integer(forKey: UserPreferences.memberId) }
        set { defaults.setValue(newValue, forKey: UserPreferences.memberId) }
    }
    
}

extension PreferencesService: ReactiveCompatible { }

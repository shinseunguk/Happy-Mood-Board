//
//  Consent.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import Foundation

struct ConsentParameters: Encodable {
    let upperFourteen: Bool
    let serviceTerms: Bool
    let privacyPolicy: Bool
    let marketingTerms: Bool
}

//
//  FirebasePathParsing.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/29/24.
//

import Foundation
import UIKit

enum FirebaseConstants {
    static let firebaseURL = "https://firebasestorage.googleapis.com/v0/b/beehappy-86cbb.appspot.com/o/"
    static let alt = "?alt=media"
}

func encodeSlash(_ input: String) -> String {
    return input.replacingOccurrences(of: "/", with: "%2F")
}

func getFirebaseURL(_ imagePath: String) -> String{
    return "\(FirebaseConstants.firebaseURL)\(encodeSlash(imagePath))\(FirebaseConstants.alt)"
}

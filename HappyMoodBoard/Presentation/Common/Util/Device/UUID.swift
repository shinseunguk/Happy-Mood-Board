//
//  UUID.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/13/24.
//

import Foundation

import UIKit

func getDeviceUUID() -> String? {
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        return uuid
    } else {
        // Handle the case where the device identifier is not available
        return nil
    }
}

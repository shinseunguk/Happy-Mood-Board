//
//  ToastMessage.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 1/23/24.
//

import Foundation
import Toast_Swift

func makeToast(_ message: String) {
    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
        let keyWindow = scene.windows.first(where: { $0.isKeyWindow })
        
        // Toast 스타일 설정
        var style = ToastStyle()
        style.messageAlignment = .center // 텍스트를 가운데 정렬
        
        keyWindow?.rootViewController?.view.makeToast(message, duration: 2.0, position: .bottom, style: style) { _ in
        }
    }
}

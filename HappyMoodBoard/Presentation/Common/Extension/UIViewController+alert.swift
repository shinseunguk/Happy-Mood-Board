//
//  UIViewController+showAlert.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation
import UIKit

import RxSwift

extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        style: UIAlertController.Style,
        actions: [AlertAction]
    ) -> Observable<Int> {
        return Observable.create { observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            actions.enumerated().forEach { index, action in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(index)
                    observer.onCompleted()
                }
                alertController.addAction(action)
            }
            
            self.present(alertController, animated: true, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// UIViewController, 확인, 취소 버튼이 있는 Alert 호출 함수
    /// - Parameters:
    ///   - title: "알림"
    ///   - message: Alert Message
    ///   - preferredStyle: Alert style (default => ".alert")
    ///   - cancelActionTitle: 취소 타이틀 set
    ///   - confirmActionTitle: 확인 타이틀 set
    ///   - confirmActionHandler: escaping closure
    func showAlert(title: String? = "알림", message: String?, preferredStyle: UIAlertController.Style = .alert, cancelActionTitle: String? = "아니오", confirmActionTitle: String? = "네", confirmActionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        // 취소 액션 추가
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // 확인 액션 추가
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { _ in
            // 확인 버튼을 눌렀을 때의 동작
            confirmActionHandler?()
        }
        alert.addAction(confirmAction)
        
        DispatchQueue.main.async {
            // 함수 호출 시점에서 해당 UIViewController에서 호출하도록 가정하고 `self`를 사용하였습니다.
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showPopUp(title: String? = nil,
                   message: String? = nil,
                   attributedMessage: NSAttributedString? = nil,
                   leftActionTitle: String? = "취소",
                   rightActionTitle: String = "확인",
                   leftActionCompletion: (() -> Void)? = nil,
                   rightActionCompletion: (() -> Void)? = nil) {
        let popUpViewController = PopUpViewController(titleText: title,
                                                      messageText: message,
                                                      attributedMessageText: attributedMessage)
        showPopUp(popUpViewController: popUpViewController,
                  leftActionTitle: leftActionTitle,
                  rightActionTitle: rightActionTitle,
                  leftActionCompletion: leftActionCompletion,
                  rightActionCompletion: rightActionCompletion)
    }
    
    func showPopUp(contentView: UIView,
                   leftActionTitle: String? = "취소",
                   rightActionTitle: String = "확인",
                   leftActionCompletion: (() -> Void)? = nil,
                   rightActionCompletion: (() -> Void)? = nil) {
        let popUpViewController = PopUpViewController(contentView: contentView)
        
        showPopUp(popUpViewController: popUpViewController,
                  leftActionTitle: leftActionTitle,
                  rightActionTitle: rightActionTitle,
                  leftActionCompletion: leftActionCompletion,
                  rightActionCompletion: rightActionCompletion)
    }
    
    private func showPopUp(popUpViewController: PopUpViewController,
                           leftActionTitle: String?,
                           rightActionTitle: String,
                           leftActionCompletion: (() -> Void)?,
                           rightActionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: leftActionTitle,
                                              titleColor: .gray500 ?? UIColor(),
                                              backgroundColor: .primary100 ?? UIColor()) {
            popUpViewController.dismiss(animated: false, completion: leftActionCompletion)
        }
        
        popUpViewController.addActionToButton(title: rightActionTitle,
                                              titleColor: .gray900 ?? UIColor(),
                                              backgroundColor: .primary500 ?? UIColor()) {
            popUpViewController.dismiss(animated: false, completion: rightActionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
}

struct AlertAction {
    var title: String
    var style: UIAlertAction.Style
    
    static func action(
        title: String,
        style: UIAlertAction.Style = .default
    ) -> AlertAction {
        AlertAction(title: title, style: style)
    }
}

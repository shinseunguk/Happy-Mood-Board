//
//  UIImagePickerController+Rx.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/02.
//

import UIKit

import RxSwift
import RxCocoa

typealias ImagePickerControllerDelegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension UIImagePickerController: HasDelegate {
    public typealias Delegate = UIImagePickerControllerDelegate & UINavigationControllerDelegate
}

extension Reactive where Base: UIImagePickerController {
    
    public var pickerDelegate: DelegateProxy<UIImagePickerController, UIImagePickerController.Delegate> {
        return RxImagePickerControllerProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Disposable {
        return RxImagePickerControllerProxy.installForwardDelegate(
            delegate,
            retainDelegate: false,
            onProxyForObject: self.base
        )
    }
    
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: Any]> {
        return pickerDelegate
            .methodInvoked(
                #selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:))
            )
            .map { try castOrThrow([UIImagePickerController.InfoKey: Any].self, $0[1]) }
    }
    
    public var didCancel: Observable<Void> {
        return pickerDelegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map {_ in () }
    }
    
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

class RxImagePickerControllerProxy
: DelegateProxy<UIImagePickerController, UIImagePickerController.Delegate>, DelegateProxyType {
    
    public weak private(set) var imagePickerController: UIImagePickerController?
    
    public init(imagePickerController: UIImagePickerController) {
        self.imagePickerController = imagePickerController
        super.init(parentObject: imagePickerController, delegateProxy: RxImagePickerControllerProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxImagePickerControllerProxy(imagePickerController: $0) }
    }
    
    public static func currentDelegate(for object: UIImagePickerController)
    -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(
        _ delegate: (UIImagePickerController.Delegate)?,
        to object: UIImagePickerController
    ) {
        object.delegate = delegate
    }
    
}

extension RxImagePickerControllerProxy: UIImagePickerControllerDelegate, UINavigationControllerDelegate { }

//
//  FirebaseStorageService.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/22.
//

import UIKit

import FirebaseStorage

import RxSwift

fileprivate enum Constants {
    static let compressionQuality: CGFloat = 0.5
    static let contentType: String = "image/jpeg"
    static let maxSize: Int64 = 100 * 1024 * 1024
}

final class FirebaseStorageService {
      
    static let shared = FirebaseStorageService()
    
    private init() {}
    
    let storage: Storage = .storage()
    
    func upload(image: UIImage, forPath path: String, completion: @escaping (StorageMetadata?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: Constants.compressionQuality) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = Constants.contentType
        let storageRef = storage.reference().child(path)
        DispatchQueue.global().async {
            storageRef.putData(imageData, metadata: metadata, completion: completion)
        }
    }
    
    func downloadImage(forPath path: String, completion: @escaping (Data?, Error?) -> Void) {
        let storageRef = storage.reference().child(path)
        DispatchQueue.global().async {
            storageRef.getData(maxSize: Constants.maxSize, completion: completion)
        }
    }
    
}

extension FirebaseStorageService: ReactiveCompatible { }

extension Reactive where Base: FirebaseStorageService {
    
    func upload(image: UIImage, forPath path: String) -> Observable<String?> {
        guard let imageData = image.jpegData(compressionQuality: Constants.compressionQuality) else { return .just(nil) }
        let metadata = StorageMetadata()
        metadata.contentType = Constants.contentType
        return base.storage.reference().child(path)
            .rx.putData(imageData, metadata: metadata)
            .map { _ in path }
    }
    
    func download(forPath path: String) -> Observable<UIImage?> {
        return base.storage.reference().child(path)
            .rx.getData(maxSize: Constants.maxSize)
            .map { data in
                return UIImage(data: data)
            }
    }
    
}

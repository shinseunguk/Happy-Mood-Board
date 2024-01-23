//
//  FirebaseStorageService.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/22.
//

import UIKit

import FirebaseStorage

import RxSwift

class FirebaseStorageService {
    
    var storage = Storage.storage()
    
    static let shared = FirebaseStorageService()
    
    func upload(image: UIImage, completion: @escaping (StorageMetadata?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let fileName = "\(getDeviceUUID() ?? "")/\(Date().timeIntervalSince1970.description)"
        let storageRef = storage.reference().child(fileName)
        DispatchQueue.global().async {
            storageRef.putData(imageData, metadata: metadata, completion: completion)
        }
    }
    
    func downloadImage(forPath path: String, completion: @escaping (Data?, Error?) -> Void) {
        let storageRef = storage.reference().child(path)
        let megaByte = Int64(100 * 1024 * 1024)

        DispatchQueue.global().async {
            storageRef.getData(maxSize: megaByte, completion: completion)
        }
    }
    
}

extension FirebaseStorageService: ReactiveCompatible { }

extension Reactive where Base: FirebaseStorageService {
    
    func upload(image: UIImage) -> Observable<String> {
        let imageData = image.jpegData(compressionQuality: 0.5)!
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let fileName = "\(getDeviceUUID() ?? "")/\(Date().timeIntervalSince1970.description)"
        return Storage.storage().reference().child(fileName)
            .rx.putData(imageData)
            .map { _ in fileName }
    }
    
    func download(forPath path: String) -> Observable<UIImage?> {
        return Storage.storage().reference().child(path)
            .rx.getData(maxSize: 100 * 1024 * 1024)
            .map { data in
                return UIImage(data: data)
            }
    }
    
}

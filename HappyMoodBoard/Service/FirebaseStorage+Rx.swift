//
//  FirebaseStorage+Rx.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/23.
//

import Foundation

import RxSwift
import FirebaseStorage

extension Reactive where Base: StorageReference {
    
    public func putData(_ uploadData: Data, metadata: StorageMetadata? = nil) -> Observable<StorageMetadata> {
        return Observable.create { observer in
            let task = self.base.putData(uploadData, metadata: metadata) { metadata, error in
                guard let error = error else {
                    if let metadata = metadata {
                        observer.onNext(metadata)
                    }
                    observer.onCompleted()
                    return
                }
                observer.onError(error)
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    public func getData(maxSize: Int64) -> Observable<Data> {
        return Observable.create { observer in
            let task = self.base.getData(maxSize: maxSize) { data, error in
                guard let error = error else {
                    if let data = data {
                        observer.onNext(data)
                    }
                    observer.onCompleted()
                    return
                }
                observer.onError(error)
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}


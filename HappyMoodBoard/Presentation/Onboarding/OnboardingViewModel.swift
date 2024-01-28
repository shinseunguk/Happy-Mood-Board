//
//  OnboardingViewModel.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/28/24.
//

import Foundation

import RxSwift

final class OnboardingViewModel : ViewModel {
    
    enum Constants {
        static let firstTitle = "행복을 담고"
        static let secondTitle = "필요할 때 꺼내봐요"
        
        static let firstSubTitle = "여러분을 행복하게 만드는 아이템을 담아보세요."
        static let secondSubTitle = "마음의 충전이 필요할 때 담았던 기록을 꺼내보세요."
        
        static let firstImage = UIImage(named: "OnBoarding.illust01") ?? UIImage()
        static let secondImage = UIImage(named: "OnBoarding.illust02") ?? UIImage()
    }
    
    struct Input {
        let nextButtonEvent: Observable<Void>
    }
    
    struct Output {
        let index: Observable<Int>
        let item: Observable<[(String, String, UIImage)]>
        let indexItem: Observable<(String, String)>
        let isHiddenButton: Observable<Bool>
        let navigateToNext: Observable<Void>
    }
    
    let index = BehaviorSubject<Int>(value: 1)
    let imageArray = Observable.of(
        [
            (Constants.firstTitle, Constants.firstSubTitle, Constants.firstImage),
            (Constants.secondTitle, Constants.secondSubTitle, Constants.secondImage)
        ]
    )
    
    func transform(input: Input) -> Output {
        let isHidden = index
            .map {
                $0 == 1
            }
        
        let indexItem = index
            .withLatestFrom(imageArray) { indexPath, array in
                let item = array[indexPath]
                return (item.0, item.1)
            }
        
        return Output(
            index: index,
            item: imageArray,
            indexItem: indexItem,
            isHiddenButton: isHidden,
            navigateToNext: input.nextButtonEvent
        )
    }
}

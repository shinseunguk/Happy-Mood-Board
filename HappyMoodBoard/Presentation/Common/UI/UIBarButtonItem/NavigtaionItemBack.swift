//
//  NavigtaionItemBack.swift
//  HappyMoodBoard
//
//  Created by ukseung.dev on 12/22/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa

final class NavigtaionItemBack: UIBarButtonItem {
    
    let view = UIView()
    lazy var customButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "navigation.back"), for: .normal)
        $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 버튼의 터치 영역을 확장합니다.
    }
    
    private let tapSubject = PublishSubject<Void>()
    
    override init() {
        super.init()
        
        view.addSubview(customButton)
        customButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(5)
        }
        
        self.customView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
        tapSubject.onNext(())
    }
    
    var rxTap: ControlEvent<Void> {
        return ControlEvent(events: tapSubject.asObservable())
    }
}

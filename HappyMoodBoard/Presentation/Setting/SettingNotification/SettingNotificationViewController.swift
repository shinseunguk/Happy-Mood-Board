//
//  SettingNotificationViewController.swift
//  HappyMoodBoard
//
//  Created by ukBook on 12/25/23.
//

import Foundation

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxViewController

import Toast_Swift


final class SettingNotificationViewController: UIViewController, ViewAttributes, UIGestureRecognizerDelegate {
    
    // 네비게이션
    private let navigationTitle = NavigationTitle(title: "알림 설정")
    private let navigationItemBack = NavigtaionItemBack()
    //
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 20
    }
    
    private let pickerView = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.locale = Locale(identifier: "ko_KR")
        $0.preferredDatePickerStyle = .wheels
        $0.backgroundColor = .white
        $0.isHidden = true
        $0.minuteInterval = 5
    }
    
    private let accessoryView = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
        
        let cornerRadius: CGFloat = 30.0
        $0.layer.cornerRadius = cornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let cancelButton = UIButton(type: .system).then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.setTitleColor(.black, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    private let saveButton = UIButton(type: .system).then {
        $0.setTitle("저장", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        $0.setTitleColor(.black, for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    private let recordPushOnOffView = TitleToggleView(type: .recordPushOnOff)
    private let titleDayOfWeekView = TitleDayOfWeekView(type: .dayOfTheWeek)
    private let titleTimeView = TitleTimeView(type: .time)
    private let marketingPushOnOffView = TitleToggleView(type: .marketingPushOnOff)
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: SettingNotificationViewModel = .init()
    
    override func viewDidLoad() {
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
}

extension SettingNotificationViewController {
    func setupNavigationBar() {
        self.navigationItem.titleView = navigationTitle
        self.navigationItem.leftBarButtonItem = navigationItemBack
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func setupSubviews() {
        [
            contentStackView,
            pickerView,
            accessoryView
        ].forEach { self.view.addSubview($0) }
        
        [
            cancelButton,
            saveButton
        ].forEach { self.accessoryView.addSubview($0) }
        
        [
            recordPushOnOffView,
            titleDayOfWeekView,
            titleTimeView,
            marketingPushOnOffView
        ].forEach { self.contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        [
            recordPushOnOffView,
            titleDayOfWeekView,
            titleTimeView,
            marketingPushOnOffView,
        ].enumerated().forEach { index, view in
//            view.layer.borderWidth = 1
            view.snp.makeConstraints {
                if index == 1 {
//                    view.layer.borderColor = UIColor.red.cgColor
                    $0.height.equalTo(80)
                } else {
                    $0.height.equalTo(40)
                }
            }
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        pickerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(216) // PickerView의 기본 높이
        }
        
        accessoryView.snp.makeConstraints {
            $0.leading.trailing.equalTo(pickerView)
            $0.bottom.equalTo(pickerView.snp.top)
            $0.height.equalTo(50)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(5)
        }
        
        saveButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(5)
        }
    }
    
    func setupBindings() {
        let input = SettingNotificationViewModel.Input(
            navigateToBack: navigationItemBack.rxTap.asObservable(),
            viewWillAppear: rx.viewWillAppear.asObservable(),
            recordPushEvent: recordPushOnOffView.actionPublishSubject,
            dayOfWeekEvent: titleDayOfWeekView.actionPublishSubject,
            timeButtonEvent: titleTimeView.timeButtonEvent,
            pickerViewEvent: pickerView.rx.date.asObservable(),
            pickerViewCancel: cancelButton.rx.tap.asObservable(),
            pickerViewSave: saveButton.rx.tap.asObservable(),
            marketingPushEvent: marketingPushOnOffView.actionPublishSubject
        )
        let output = viewModel.transform(input: input)
        
        output.navigateToBack.bind { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 행복아이템 기록 알림 받기
        output.recordPush
            .bind { [weak self] handler in
                self?.recordPushOnOffView.togglePublishSubject.onNext(handler)
                
                if handler {
                    self?.titleDayOfWeekView.isUserInteractionEnabled = true
                    self?.titleTimeView.isUserInteractionEnabled = true
                    
                    self?.titleDayOfWeekView.backgroundColor = .primary100
                    self?.titleTimeView.backgroundColor = .primary100
                } else {
                    self?.titleDayOfWeekView.isUserInteractionEnabled = false
                    self?.titleTimeView.isUserInteractionEnabled = false
                    
                    self?.titleDayOfWeekView.backgroundColor = .black.withAlphaComponent(0.3)
                    self?.titleTimeView.backgroundColor = .black.withAlphaComponent(0.3)
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - 요일
        output.dayOfWeek.asDriver(onErrorJustReturn: [])
            .drive(titleDayOfWeekView.dayOfWeekPublicSubject)
            .disposed(by: disposeBag)
        
        // MARK: - 최소 1개 이상의 요일을 선택하지 않았을때 => 뒤로가기 제스쳐 막기, 네비게이션 LeftbarButtonItem Disable, toast
        output.dayOfWeek
            .map {
                $0.count == 0
            }
            .subscribe(onNext: { [weak self] in
                self?.navigationItemBack.isEnabled = !$0
                self?.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                
                $0 ? makeToast("최소 1개 이상의 요일을 선택해 주세요.") : nil
            })
            .disposed(by: disposeBag)
        
        // MARK: - 시간
        output.pushTime
            .bind { [weak self] in
                self?.titleTimeView.timePublishSubject.onNext($0)
                if let setUpDate = convertStringToDate(dateString: $0, dateFormat: "HH:mm") {
                    traceLog(setUpDate)
                    
                    self?.hiddenPickerView(true)
                    self?.pickerView.date = setUpDate
                } else {
                    self?.pickerView.date = Date()
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: - stackview의 시간 버튼 터치
        output.timeButtonEvent.bind { [weak self] _ in
            self?.hiddenPickerView(false)
        }
        .disposed(by: disposeBag)
        
        // MARK: - Date PickerView에 accessoryView [취소]버튼 터치
        output.pickerViewCancel.bind { [weak self] _ in
            self?.hiddenPickerView(true)
        }
        .disposed(by: disposeBag)
        
        // MARK: - 이벤트·혜택 알림 받기
        output.marketingPush
            .skip(1)
            .bind { [weak self] in
            self?.marketingPushOnOffView.togglePublishSubject.onNext($0)
            
            let currentDate = getCurrentDateFormatted()
            makeToast("\(currentDate)에 Bee Happy의 마케팅 정보 수신을 \($0 ? "동의" : "철회")했어요.")
        }
        .disposed(by: disposeBag)
        
        output.viewWillAppearErrorMessage.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
        
        output.recordPushErrorMessage.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
        
        output.dayOfWeekErrorMessage.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
        
        output.pushTimeErrorMessage.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
        
        output.marketingErrorMessage.bind {
            makeToast($0)
        }
        .disposed(by: disposeBag)
    }
    
    func hiddenPickerView(_ handler: Bool) {
        self.pickerView.isHidden = handler
        self.accessoryView.isHidden = handler
    }
}

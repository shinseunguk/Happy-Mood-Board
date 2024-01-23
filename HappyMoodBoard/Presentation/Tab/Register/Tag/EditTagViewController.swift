//
//  EditTagViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/19.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa
import RxDataSources

final class EditTagViewController: UIViewController {
    
    enum Constants {
        static let deleteAlertTitle = "태그를 삭제 하시겠어요?"
        static let deleteAlertMessage = "동일한 태그를 사용한 모든 글에서 태그가 삭제돼요."
        static let deleteAlertNoAction = "아니오"
        static let deleteAlertYesActon = "네"
    }
    
    private let tableView: UITableView = .init().then {
        $0.register(EditTagTableViewCell.self, forCellReuseIdentifier: EditTagTableViewCell.reuseIdentifier)
        $0.backgroundColor = .clear
        $0.isEditing = true
        $0.separatorStyle = .none
    }
    
    private let completeButton = UIButton(type: .system).then {
        $0.configurationUpdateHandler = { button in
            var container = AttributeContainer()
            container.font = UIFont(name: "Pretendard-Medium", size: 18)
            container.foregroundColor = button.isEnabled ? .gray900 : .gray400
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .capsule
            configuration.background.backgroundColor = button.isEnabled ? .primary500 : .gray200
            configuration.attributedTitle = AttributedString("편집 완료", attributes: container)
            button.configuration = configuration
        }
    }
    
    private let viewModel: EditTagViewModel = .init()
    private let disposeBag: DisposeBag = .init()
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<EditTagSection> = .init(
        configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EditTagTableViewCell.reuseIdentifier
            ) as? EditTagTableViewCell else {
                return .init()
            }
            cell.nameLabel.text = item.tagName
            return cell
        },
        canEditRowAtIndexPath: { _, _ in return true }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

extension EditTagViewController: ViewAttributes {
    func setupNavigationBar() {
        navigationItem.title = "태그 편집"
    }
    
    func setupSubviews() {
        [
            tableView,
            completeButton
        ].forEach { view.addSubview($0) }
    }
    
    func setupLayouts() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.height.equalTo(52)
        }
    }
    
    func setupBindings() {
        let deleteOkActionTapped: PublishSubject<Tag> = .init()
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let input = EditTagViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            itemDeleted: tableView.rx.modelDeleted(Tag.self).asObservable(),
            itemAccessoryButtonTapped: tableView.rx.itemAccessoryButtonTapped.asObservable(),
            deleteOkActionTapped: deleteOkActionTapped
        )
        let output = viewModel.transform(input: input)
        output.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showDeleteAlert
            .map { Optional($0) }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .map { $0! } // asDriverSkippingErrors
            .drive(with: self) { owner, tag in
                owner.showPopUp(
                    title: Constants.deleteAlertTitle,
                    message: Constants.deleteAlertMessage,
                    leftActionTitle: Constants.deleteAlertNoAction,
                    rightActionTitle: Constants.deleteAlertYesActon,
                    rightActionCompletion: {
                        deleteOkActionTapped.onNext((tag))
                    }
                )
            }
            .disposed(by: disposeBag)
        
        output.navigateToEdit
            .map { Optional($0) }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .map { $0! }
            .drive(with: self) { owner, tag in
                // TODO: viewModel 수정
                let viewController = AddTagViewController()
                owner.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - UITableViewDelegate

extension EditTagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
}

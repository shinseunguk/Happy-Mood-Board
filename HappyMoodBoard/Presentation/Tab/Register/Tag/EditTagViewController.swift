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
    
    private var items: BehaviorSubject<[EditTagSection]> = .init(value: [.init(header: "", items: [])])
    private var dataSource: RxTableViewSectionedAnimatedDataSource<EditTagSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppear()
    }
    
}

extension EditTagViewController {
    
    func viewWillAppear() {
        ApiService()
            .request(type: [Tag].self, target: TagTarget.fetch())
            .debug()
            .compactMap { [EditTagSection(header: "", items: $0 ?? [])] }
            .subscribe { [weak self] sections in
                self?.items.on(sections)
            }
            .disposed(by: disposeBag)
    }
    
    func itemDeleted(indexPath: IndexPath) {
        guard var sections = try? items.value() else { return }
        var currentSection = sections[indexPath.section]
        let id = currentSection.items[indexPath.row].id
        ApiService()
            .request(type: Empty.self, target: TagTarget.delete(id))
            .debug()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self] _ in
                self?.tableView.beginUpdates()
                self?.items.onNext(sections)
                self?.tableView.endUpdates()
//                currentSection.items.remove(at: indexPath.row)
//                sections[indexPath.section] = currentSection
//                self?.users.onNext(sections)
            }
            .disposed(by: disposeBag)
    }
    
    func itemAccessoryButtonTapped(indexPath: IndexPath) {
        guard var sections = try? items.value() else { return }
        var currentSection = sections[indexPath.section]
        let item = currentSection.items[indexPath.row]
        print(item)
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
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedAnimatedDataSource<EditTagSection>(
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
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let itemDeleted = tableView.rx.itemDeleted
            .share()
        
        itemDeleted
            .map { Optional($0) }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .map { $0! } // asDriverSkippingErrors
            .drive(with: self) { owner, indexPath in
                owner.itemDeleted(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
        let itemAccessoryButtonTapped = tableView.rx.itemAccessoryButtonTapped
            .share()
        
        itemAccessoryButtonTapped
            .map { Optional($0) }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .map { $0! }
            .drive(with: self) { owner, indexPath in
                owner.itemAccessoryButtonTapped(indexPath: indexPath)
            }
            .disposed(by: disposeBag)
        
//        Observable.merge(
//            rx.viewWillAppear.map { _ in }.asObservable(),
//            itemDeleted.map { _ in }
//        )
//            .subscribe(onNext: { [weak self] _ in
//                self?.viewWillAppear()
//            })
//            .disposed(by: disposeBag)
    }
    
}

// MARK: - UITableViewDelegate

extension EditTagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
}

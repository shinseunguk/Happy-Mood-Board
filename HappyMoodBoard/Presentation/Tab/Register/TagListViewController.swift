//
//  TagListViewController.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

enum TagListItemType {
    case tag(Tag)
    case add
}

final class TagListViewController: UIViewController {
    
    private let editButton: UIBarButtonItem = .init(systemItem: .edit)
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let verticalInset: CGFloat = 32
        let horizontalInset: CGFloat = 24
        layout.sectionInset = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        layout.itemSize = .init(width: 73, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")
        collectionView.backgroundColor = .primary100
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private let closeButton: UIButton = .init(type: .system).then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.gray900, for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        // TODO: 밑줄
    }
    
    private let disposeBag: DisposeBag = .init()
    private let viewModel: TagListViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCommonBackgroundColor()
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        setupBindings()
    }
    
}

extension TagListViewController: ViewAttributes {
    
    func setupNavigationBar() {
        navigationItem.title = "태그 선택"
        let spacing = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacing.width = 20
        navigationItem.rightBarButtonItems = [editButton, spacing]
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setupSubviews() {
        view.addSubview(contentStackView)
        
        [
            collectionView,
            closeButton
        ].forEach { contentStackView.addArrangedSubview($0) }
    }
    
    func setupLayouts() {
        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(41)
        }
    }
    
    func setupBindings() {
        let input = TagListViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            editButtonTapped: editButton.rx.tap.asObservable(),
            itemSelected: collectionView.rx.modelSelected(TagListItemType.self).asObservable(),
            closeButtonTapped: closeButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.navigateToEdit.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let viewController = UIViewController()
                viewController.sheetPresentationController?.detents = [.medium()]
                viewController.sheetPresentationController?.prefersGrabberVisible = true
                owner.show(viewController, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.items.asDriver(onErrorJustReturn: [])
            .drive(
                collectionView.rx.items(
                    cellIdentifier: "TagCollectionViewCell",
                    cellType: TagCollectionViewCell.self
                )
            ) { _, element, cell in
                switch element {
                case .tag(let tag):
                    var configuration = UIButton.Configuration.filled()
                    configuration.cornerStyle = .capsule
                    let verticalInset: CGFloat = 4.5
                    let horizontalInset: CGFloat = 24
                    configuration.contentInsets = .init(
                        top: verticalInset,
                        leading: horizontalInset,
                        bottom: verticalInset,
                        trailing: horizontalInset
                    )
                    configuration.background.backgroundColor = .tagColor(for: tag.tagColorId)
                    var container = AttributeContainer()
                    container.font = UIFont(name: "Pretendard-Medium", size: 14)
                    container.foregroundColor = .gray900
                    configuration.attributedTitle = .init(tag.tagName, attributes: container)
                    cell.nameButton.configuration = configuration
                    cell.nameButton.titleLabel?.numberOfLines = 1
                case .add:
                    cell.nameButton.setImage(.init(named: "add"), for: .init())
                }
            }
            .disposed(by: disposeBag)
        
        output.navigateToAdd.asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigateToAdd()
            }
            .disposed(by: disposeBag)
        
        output.dismiss.asDriver(onErrorJustReturn: nil)
            .drive(with: self) { owner, tag in
                owner.navigatToBack(tag)
            }
            .disposed(by: disposeBag)
    }
    
    func navigatToBack(_ tag: Tag?) {
        dismiss(animated: true) { [weak self] in
            print(tag)
        }
    }
    
    func navigateToAdd() {
        let viewController = AddTagViewController()
        show(viewController, sender: nil)
    }
}

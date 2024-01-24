//
//  TagCollectionViewCell.swift
//  HappyMoodBoard
//
//  Created by 홍다희 on 2024/01/09.
//

import UIKit

import Then
import SnapKit

final class TagCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TagCollectionViewCell"
    
    let nameButton: UIButton = .init(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nameButton)
        nameButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        nameButton.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: TagListItem) {
        switch item {
        case .add:
            var configuration = UIButton.Configuration.plain()
            configuration.preferredSymbolConfigurationForImage = .init(pointSize: 30)
            configuration.image = .init(named: "add")
            configuration.imagePadding = .zero
            nameButton.configuration = configuration
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
            nameButton.configuration = configuration
            nameButton.titleLabel?.numberOfLines = 1
        }
    }

}

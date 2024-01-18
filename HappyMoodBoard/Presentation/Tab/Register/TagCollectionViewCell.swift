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

}

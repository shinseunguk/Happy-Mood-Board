//
//  OnboardingCollectionViewCell.swift
//  HappyMoodBoard
//
//  Created by ukBook on 1/28/24.
//

import Foundation

import UIKit


final class OnboardingCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension OnboardingCollectionViewCell {
    func bindData(image: UIImage) {
        imageView.image = image
    }
}

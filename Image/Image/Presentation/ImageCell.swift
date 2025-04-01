//
//  ImageCel.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let identifier = NSStringFromClass(ImageCell.self)
    
    // MARK: - Properties
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    // MARK: - Inaitalizer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func updateCell(with image: UIImage) {
        imageView.image = image
    }
    
    // MARK: - Private

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
}

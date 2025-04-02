//
//  PinteresetLayout.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import UIKit

@MainActor protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAt indexPath: IndexPath
    ) -> CGFloat
}

final class PinterestLayout: UICollectionViewFlowLayout {
    
    // MARK: - Delegate
    
    weak var delegate: (any PinterestLayoutDelegate)?
    
    
    // MARK: - Properties
    
    private let numberOfColumns: Int
    private let cellPadding: CGFloat = 6
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private var contentHeight: CGFloat = 0
    
    
    // MARK: - Intializer
    
    init(
        _ numberOfColumns: Int = 2,
        delegate: (any PinterestLayoutDelegate)?
    ) {
        self.delegate = delegate
        self.numberOfColumns = numberOfColumns
       
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Content Size
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    
    // MARK: - Prepare
    
    override func prepare() {
        print(#function)
        guard
            cache.isEmpty,
            let collectionView = collectionView
        else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffset: [CGFloat] = Array(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForPhotoAt: indexPath
            ) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            let insetFrame = frame.insetBy(
                dx: cellPadding,
                dy: cellPadding
            )
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            if let minYOffset = yOffset.min(),
               let targetColumn = yOffset.firstIndex(of: minYOffset) {
                column = targetColumn
            }
        }
    }
    
    
    // MARK: - Layout Attributes for Elements
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print(#function)
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        print(#function)
//        return cache[indexPath.item]
//    }
    
}

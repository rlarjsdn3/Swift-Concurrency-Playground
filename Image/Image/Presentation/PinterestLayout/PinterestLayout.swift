//
//  PinteresetLayout.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAt indexPath: IndexPath
    ) -> CGFloat
}

final class PinterestLayout: UICollectionViewFlowLayout {
    
    weak var delegate: PinterestLayoutDelegate?
    
    
    
}

//
//  ViewController.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import UIKit

class ImageViewController: UIViewController {

    // MARK: - Properties
    
    private var viewModel: ImageViewModel!
    
    private var collectionView: UICollectionView!
    
    
    // MARK: - Intializer
    
    init(viewModel: ImageViewModel!) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private
    
    private func setupUI() {
        let layout = PinterestLayout(delegate: self)
        
        collectionView = UICollectionView(
            frame: self.view.bounds,
            collectionViewLayout: layout
        )
        view.addSubview(collectionView)
        
        collectionView.register(
            ImageCell.self,
            forCellWithReuseIdentifier: ImageCell.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }


}

// MARK: - Extensions

extension ImageViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return appData.items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCell.identifier,
            for: indexPath) as? ImageCell else {
            return .init()
        }
        
//        cell.backgroundColor = .systemGray
        return cell
    }
}

extension ImageViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let cell = cell as! ImageCell
        
        Task {
            // print("ImageViewController: \(Thread.isMainThread)")
            if let data = await viewModel.downloadImage(at: indexPath) {
                let image = UIImage(data: data)!
                cell.updateCell(with: image)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        viewModel.cancel(at: indexPath)
    }
}


extension ImageViewController: PinterestLayoutDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAt indexPath: IndexPath
    ) -> CGFloat {
        return CGFloat.random(in: 50..<200)
    }
}

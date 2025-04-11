//
//  ViewControllerFactory.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

@MainActor final class Factory {
    
    static func makeImageViewController() -> ImageViewController {
        let imageDatabase = ImageDatabase.shared
        let imageViewModel = ImageViewModel(imageDatabase: imageDatabase)
        let imageViewController = ImageViewController(viewModel: imageViewModel)
        return imageViewController
    }
}

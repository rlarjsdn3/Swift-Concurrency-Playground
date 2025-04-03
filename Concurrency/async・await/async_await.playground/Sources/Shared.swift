import UIKit

public let url = "https://picsum.photos/1000"

public func prepareThumbnail(from image: UIImage,
                             compeltion: @Sendable @escaping (UIImage?) -> Void) {
    image.prepareThumbnail(of: CGSize(width: 100, height: 100),
                           completionHandler: compeltion)
}




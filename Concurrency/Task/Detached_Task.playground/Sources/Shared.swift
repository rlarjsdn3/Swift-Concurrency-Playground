import UIKit

public class MyDelegate: NSObject {
    public var thumbnailTasks: [IndexPath: Task<Void, Never>] = [:]
    
    public func getThumbnailIDs(for indexPath: IndexPath) -> [IndexPath] { [indexPath] }
    
    public func fetchThumbnails(for items: [IndexPath]) async -> UIImage { UIImage(systemName: "sun.max")! }
    
    public func display(_ thumbnail: UIImage, in cell: UICollectionViewCell) {
    }
    
    public func writeToLocalCache(_ thumbnails: UIImage) {
    }
}

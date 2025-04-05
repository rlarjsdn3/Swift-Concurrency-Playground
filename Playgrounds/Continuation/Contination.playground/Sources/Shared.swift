import UIKit

public let url = "https://picsum.photos/1000"

@available(*, deprecated)
public func downloadImage(from url: String,
                    completion: @Sendable @escaping (Result<UIImage, any Error>) -> Void) {
    
    let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
        if let _ = error {
            completion(.failure(URLError(.unknown)))
            return
        } else {
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(URLError(.unknown)))
                return
            }
            
            if let data = data,
               let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(URLError(.unknown)))
            }
            return
        }
    }
    
    task.resume()
}



public struct Post {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

public protocol PeerSyncDelegate: AnyObject {
    func peerManager(_ manager: PeerManager, received posts: [Post])
    func peerManager(_ manager: PeerManager, hadError error: Error)
}

public class PeerManager {
    public weak var delegate: (any PeerSyncDelegate)?
    public init() { }
    public func syncSharedPosts() {
        delegate?.peerManager(self, received: [])
    }
}

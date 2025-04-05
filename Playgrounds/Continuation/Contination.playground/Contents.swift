import UIKit

//: ---
//: # Continuation
//: ## 콜백 방식의 함수를 async/await으로 전환하는 방법
//: ---
//: Swift Concurrency는 더 안전하고 이해하기 쉬운 방식이지만,
//: 기존의 콜백 기반 API를 모두 async/await 형태로 바꾸는 작업은 매우 번거롭고 반복적일 수 있습니다.
//:
//: 이러한 번거로움을 줄이기 위해, Swift는 비동기 흐름을 일시 중단(suspend)하고,
//: 개발자가 원하는 시점에 다시 이어갈 수 있도록 돕는 객체를 도입했습니다. 바로 `컨티뉴에이션(Continuation)`입니다.

//: `컨티뉴에이션(Continuation)`을 사용하면 기존 콜백 기반 API를 async/await 형태로 바꿀 수 있습니다.
//: 아래 예제는 우리가 익숙하게 사용하던 `downloadImage(from:completion:)` 메서드를 Swift Concurrency 스타일로 전환하는 방법을 보여줍니다.

//: ---
//: ### 예제 1
func downloadImageAsynchronously(from url: String) async throws -> UIImage {
    try await withCheckedThrowingContinuation { continuation in
        downloadImage(from: url) { result in
            switch result {
            case .success(let image):
                continuation.resume(returning: image)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
Task { try? await downloadImageAsynchronously(from: url) }
//: ---

//: 먼저, `downloadImageAsynchronously(from:)` 함수를 정의하고,
//: 반환 타입으로 `async throws -> UIImage`를 지정합니다. 이는 함수가 비동기적으로 동작하며 오류를 던질 수 있다는 것을 나타냅니다.
//: 함수 내부에서는 기존의 콜백 기반 메서드인 `downloadImage(from:completion:)`를 호출합니다.
//: 이 때, `withCheckedThrowingContinuation`을 사용하여 비동기 흐름을 일시 중단(suspend)하고,
//: 콜백이 완료되는 시점에 `continuation.resume(returning:)` 또는 `continuation.resume(throwing:)`을 호출하여 흐름을 재개(resume)합니다.


//: 이때, `resume` 메서드는 **모든 실행 흐름에서 반드시 한 번만 호출**되어야 합니다.
//: 만약 `resume`을 호출하지 않으면 해당 비동기 작업은 영원히 일시 중단된 상태로 남게 되어, 앱에서 메모리 누수와 같은 문제가 발생할 수 있습니다.
//: 반대로 `resume`을 **두 번 이상 호출하는 것도 허용되지 않으며**, 이 경우 런타임 경고가 출력됩니다. (`withCheckedContinuation` 사용 시 해당 동작 감지)
//: 따라서 모든 분기에서 정확히 한 번만 `resume`이 호출되도록 해야 합니다.




//: 델리게이트 기반 API도 `컨티뉴에이션(Continuation)`을 사용하면 async/await 형태로 전환할 수 있습니다.
//: Swift Concurrency 스타일로 전환된 델리게이트 메서드는 실제로 데이터가 생성되는 시점에 `resume`을 호출하여 작업을 재개합니다.
//: 이를 위해 컨티뉴에이션 객체를 외부 변수에 저장해두고, 델리게이트 콜백이 호출되는 시점에 해당 컨티뉴에이션을 적절히 재개시켜야 합니다.

//: ---
//: ### 예제 2
public class ViewController: UIViewController {
    private var peerManager: PeerManager!
    private var activeContinuation: CheckedContinuation<[Post], Error>?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        peerManager = PeerManager()
        peerManager.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func sharedPostsFromPeer() async throws -> [Post] {
        try await withCheckedThrowingContinuation { continuation in
            self.activeContinuation = continuation
            self.peerManager.syncSharedPosts()
        }
    }
}

extension ViewController: PeerSyncDelegate {
    public func peerManager(_ manager: PeerManager, received posts: [Post]) {
        self.activeContinuation?.resume(returning: posts)
        self.activeContinuation = nil // guard against multiple calls to resume
    }

    public func peerManager(_ manager: PeerManager, hadError error: Error) {
        self.activeContinuation?.resume(throwing: error)
        self.activeContinuation = nil // guard against multiple calls to resume
    }
}
//: ---



//: 컨티뉴에이션에는 네 가지 종류가 존재합니다:
//: ---
//: - `withCheckedContinuation()`
//: - `withCheckedThrowingContinuation()`
//: - `withUnsafeContinuation()`
//: - `withUnsafeThrowingContinuation()`
//: ---

//: `Throwing`이 붙은 컨티뉴에이션은 콜백 기반 API가 **오류를 던질 수 있는 경우**에 사용합니다.
//: 이 경우, 콜백에서 오류가 발생하면 `resume(throwing:)`을 호출하고,
//: 정상적인 결과가 있다면 `resume(returning:)`을 호출하여 비동기 작업을 재개해야 합니다.

//: `Unsafe`가 붙은 컨티뉴에이션은 런타임에서 사용법을 검사하지 않는 비검사 버전입니다.
//: 예를 들어 `resume`이 호출되지 않거나, 두 번 이상 호출되더라도 경고 로그가 출력되지 않습니다.
//: 대신 `CheckedContinuation`보다 **성능 상의 이점**이 있을 수 있으나,
//: 사용 시에는 반드시 **모든 경로에서 정확히 한 번만 `resume`이 호출되도록** 주의 깊게 설계해야 합니다.


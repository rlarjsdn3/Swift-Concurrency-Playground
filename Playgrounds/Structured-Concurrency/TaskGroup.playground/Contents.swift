import UIKit

//: ---
//: ## TaskGroup
//: ### 구조적 동시성, 비동기 함수를 병렬로 실행하는 두 번째 방법
//: ---
//: 앞서 우리는 `async let`을 사용해 **동시적 바인딩(concurrent binding)**으로
//: 여러 하위 작업을 병렬(parallel)로 실행하는 방법을 살펴보았습니다.
//:
//: 이 방식은 매우 직관적이고 간단하지만, 한 가지 **치명적인 한계점**이 있습니다.
//: 바로 **확장성이 떨어진다**는 점입니다.
//:
//: `async let`은 **정해진 개수의 작업을 병렬로 처리해야 할 때**에만 적합합니다.
//: 예를 들어, 서로 다른 5개의 고정된 통계 데이터를 각각 계산해 화면에 보여주는 경우엔 매우 유용하죠.
//:
//: 하지만 만약 작업의 개수가 **동적으로 결정**되는 상황이라면 어떻게 해야 할까요?
//: 예를 들어, 서버에서 사용자가 작성한 **게시글 목록을 비동기적으로 가져오는 상황**을 가정해보겠습니다.

//: ---
//: ### 예제 1
func fetchPosts() async -> [Post] {
    async let post1 = fetchPost(for: 1)
    async let post2 = fetchPost(for: 2)
    async let post3 = fetchPost(for: 3)
    // 🟡 만약 가져와야 할 게시글의 수가 더 많아진다면?

    let posts = try! await [post1, post2, post3]
    return posts
}
Task { await fetchPosts() }
//: ---

//: 위 코드는 지금 당장은 문제 없어 보일 수 있습니다.
//: 하지만 게시글 수가 늘어나고, 서버에서 받아야 할 데이터 양이 많아지면
//: `async let`으로 **일일이 하드코딩하는 방식은 한계**에 부딪힐 수밖에 없습니다.
//:
//: 이런 경우에는 작업의 개수만큼 유동적으로 생성하고 병렬로 실행할 수 있는
//: **`TaskGroup`이 훨씬 더 적합한 해결책**이 됩니다.
//:
//: 아래 예제는 위의 `async let` 기반 코드를 **작업 그룹(TaskGroup)** 방식으로 개선한 예제입니다.

//: ---
//: ### 예제 2
func fetchPosts(until id: Int) async -> [Post] {
    await withTaskGroup(of: Post?.self, returning: [Post].self) { group in
        for id in 0..<id {
            group.addTask {
                try? await fetchPost(for: id)
            }
        }
        
        var posts: [Post] = []
        
        for await post in group {
            if let post = post {
                posts.append(post)
            }
        }
        return posts
    }
}
Task { await fetchPosts(until: 100) }
//: ---

//: `of` 매개변수에는 **각 하위 작업이 반환하는 값의 타입**을 명시합니다.
//: 반면, `returning` 매개변수에는 **작업 그룹(TaskGroup)이 최종적으로 반환할 결과의 타입**을 적습니다.


//: `fetchPosts(until:)` 비동기 함수를 호출해 `작업 그룹`을 사용하면 내부적으로 어떤 일이 일어날까요?
//:
//: `Swift 컴파일러`는 `fetchPosts(until:)` 함수를 하나의 **상위 작업(Parent Task)**으로 처리하고,
//: 그 안에서 선언된 100여 개의 게시글 다운로드 작업을 **하위 작업(Child Tasks)**으로 구성하는 **작업 트리(Task Tree)**를 생성합니다.

//: ---
//: 📦 fetchPosts(until:)  ← 상위 작업 (Parent Task)
//:  ├── 🧵 fetchPost(for:)  ← 하위 작업 1
//:  ├── 🧵 fetchPost(for:)  ← 하위 작업 2
//:  ├── 🧵 ...
//:  └── 🧵 fetchPost(for:)  ← 하위 작업 100
//: ---

//: 이때 상위 작업은 **모든 하위 작업이 완료되어야** 종료될 수 있으며,
//: `fetchPosts(until:)` 함수도 하위 작업들이 끝나야 **완전히 반환**됩니다.
//:
//: 즉, 이 비동기 작업들은 모두 `downloadImagesParallel()` 함수의 **정적 스코프(static scope)** 내에서만
//: 유효하게 실행되며, 함수 밖의 다른 컨텍스트에 영향을 주지 않습니다.
//:
//: 덕분에 우리는 코드의 실행 범위를 명확하게 파악할 수 있고,
//: 더 안전하고 예측 가능한 비동기 코드를 작성할 수 있게 됩니다.


//: 여기서 주목해야 할 또 하나의 포인트는 바로 `for-await-in` 구문입니다.
//:
//: 이 구문은 **비동기 루프**로, 작업 그룹(TaskGroup)에 추가된 하위 작업 중 **완료된 작업 결과가 순차적으로 루프에 전달**될 때마다 실행됩니다.
//:
//: 중요한 점은, 작업이 추가된 순서대로 루프를 도는 것이 아니라, 완료된 순서대로 처리된다는 것입니다. 즉, 더 빨리 끝나는 작업이 먼저 루프에 전달되어 실행됩니다.
//:
//: 이 `for-await-in` 구문은 Swift에서 제공하는 **비동기 시퀀스(Asynchronous Sequence)**의 한 예이며, 이에 대한 자세한 내용은 [애플 공식 문서](https://developer.apple.com/documentation/swift/asyncsequence)를 참조하세요.



//: 작업 그룹에는 여러 종류가 존재합니다.
//: ---
//: - `withTaskGroup(of:returning:body:)`
//: - `withThrowingTaskGroup(of:returning:body:)`
//: - `withDiscardingTaskGroup(returning:body:)`
//: - `withThrowingDiscardingTaskGroup(returning:body:)`
//: ---

//: `Throwing`이 붙은 작업 그룹은 하위 작업 중 **오류를 던질 수 있는 작업**이 있을 때 사용합니다.
//: 만약 어느 하나의 하위 작업이라도 예외를 던지면, 작업 그룹은 즉시 나머지 모든 하위 작업에 취소(cancel)를 전파하고,
//: 모든 하위 작업이 종료된 이후에 **예외를 전달하며 함수에서 빠져나갑니다.**.

//: `Discarding`이 붙은 작업 그룹은 **결과값을 따로 저장하거나 반환할 필요가 없는 작업**에서 사용합니다.
//: 예를 들어, 각 하위 작업이 `Void`를 반환하거나, 단순히 사이드 이펙트(side-effect)를 유발하는 작업에 적합합니다.

//: `DiscardingTaskGroup`은 각 하위 작업이 완료되자마자 **즉시 메모리에서 제거되도록(eager discard)** 설계되어 있기 때문에, **`TaskGroup`보다 메모리 효율이 뛰어납니다.**
//: 이는 특히 하위 작업의 수가 많고, 결과값이 필요 없는 경우에 유리합니다.

//: ---
//: ### 예제 3
func cachingPosts(ids: [Int]) async throws {
    try await withThrowingDiscardingTaskGroup { group in
        for id in ids {
            group.addTask {
                try await cachingPost(id: id)
            }
        }
    }
}
Task { try? await cachingPosts(ids: [1, 2, 3]) }
//: ---

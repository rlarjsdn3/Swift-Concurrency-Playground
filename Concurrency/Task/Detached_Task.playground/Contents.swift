import UIKit

//: ---
//: ## Detached Task
//: ### 비동기 작업의 기본 단위
//: ---
//: 그렇다면 `Task`의 짝꿍인 `Detached Task`는 무엇일까요? 🤔
//: 일반적인 `Task`는 생성된 위치의 `우선순위`, `액터`, `Task-Local 변수` 등 다양한 자원을 상속받아 실행됩니다.
//: 반면에 `Detached Task`는 이러한 자원을 전혀 상속하지 않고, 완전히 독립적인 컨텍스트에서 실행되는 작업입니다.
//: 즉, 바깥 작업과의 연결 없이 **스스로 독립된 비동기 작업**을 실행할 때 사용됩니다.

//: ---
//: ### 예제 1
let task1 = Task(priority: .userInitiated) {
    print("😃 Task1의 작업 우선순위: \(Task.currentPriority)")
    
    let task2 = Task.detached {
        print("😃 Task2의 작업 우선순위: \(Task.currentPriority)")
    }
}
// Print "😃 Task1의 작업 우선순위: TaskPriority.high"
// Print "😃 Task2의 작업 우선순위: TaskPriority.medium"
//: ---

//: 위 예제에서 `task1`은 `userInitiated` 우선순위로 생성된 작업입니다.
//: 그 내부에서 생성된 `task2`는 `Detached Task`이기 때문에, `task1`의 자원을 상속받지 않습니다. 따라서 `task2`의 우선순위는 `medium`이 됩니다.


//: 그렇다면 `Detached Task`는 어떻게 활용할 수 있을까요?
//: WWDC에서는 이미지 썸네일을 다운로드하여 컬렉션 뷰 셀에 표시하고,
//: 동시에 **디스크 캐시에 저장하는 작업**에 `Detached Task`를 활용하는 예제를 소개했습니다.

//: ---
//: ### 예제 2
@MainActor
extension MyDelegate: UICollectionViewDelegate {
    public func collectionView(_ view: UICollectionView,
                               willDisplay cell: UICollectionViewCell,
                               forItemAt item: IndexPath) {
        let ids = getThumbnailIDs(for: item)
        thumbnailTasks[item] = Task {
            defer { thumbnailTasks[item] = nil}
            let thumbnails = await fetchThumbnails (for: ids)
            Task.detached(priority: .background) {
                self.writeToLocalCache(thumbnails)
            }
            display (thumbnails, in: cell)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        thumbnailTasks[indexPath]?.cancel()
        thumbnailTasks[indexPath] = nil
    }
}
//: ---

//: 위 예제에서는 `collectionView(_:willDisplay:)` 메서드 안에서
//: 셀이 화면에 표시되기 직전에 썸네일을 비동기로 불러옵니다.
//:
//: 썸네일 로딩 작업은 일반적인 `Task`로 실행되며, 이는 취소가 가능합니다.
//: 썸네일이 성공적으로 로딩되면, 이 이미지를 디스크에 저장하는 작업을 `Task.detached`로 실행합니다.
//:
//: `writeToLocalCache(_:)`는 디스크 I/O와 같은 **무거운 백그라운드 작업**입니다.
//: 이 작업은 **UI 컨텍스트나 우선순위의 영향을 받지 않아도 되는 독립 작업**이므로, `Task.detached(priority: .background)`로 분리하여 처리합니다.






//: ---
//: ## 부록 (구조화된 동시성 vs. 구조화되지 않은 동시성)
//: ---
//:
//: 항목               | 구분               | 성격         | 취소 전파           | 자원 상속
//: -------------------------------------------------------------------------------
//: `async-let`        | 구조화된 동시성      | 간결/스코프 제한 | ✅ 가능         | ✅ 가능
//: `TaskGroup`        | 구조화된 동시성      | 높은 확장성     | ✅ 가능         | ✅ 가능
//: `Task`             | 구조화되지 않은 동시성 | 유연한 제어     | ❌ 불가능       | ✅ 가능
//: `Task.detached`    | 구조화되지 않은 동시성 | 완전 독립 실행   | ❌ 불가능       | ❌ 불가능
//: -------------------------------------------------------------------------------


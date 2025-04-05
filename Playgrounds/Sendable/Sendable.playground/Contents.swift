import UIKit

//: ---
//: # Sendable
//: ## 서로 다른 스레드(비동기 컨텍스트) 간에 안전하게 공유될 수 있는 타입
//: ---

//: Swift 5.5에서 도입된 Swift Concurrency는 비동기 코드의 안정성과 가독성을 높이기 위해 설계되었습니다.
//: 그 핵심 목표 중 하나는 **컴파일 타임에 데이터 경합(race condition)의 가능성을 감지하고 방지하는 것**입니다.
//:
//: 기존의 `GCD(Grand Central Dispatch)` 기반 비동기 코드에서는
//: 서로 다른 스레드에서 발생할 수 있는 데이터 충돌을 컴파일러가 미리 알려주지 않으며,
//: 런타임에 문제가 발생하더라도 디버깅이 매우 어렵다는 한계가 있었습니다.
//:
//: 이를 해결하기 위해 Swift는 `Sendable`이라는 새로운 프로토콜을 도입했습니다.
//: `Sendable`은 특정 값이 **다른 스레드 간 안전하게 전달될 수 있음을 보장**하며,
//: 이를 통해 **동시성 환경에서의 데이터 안전성을 컴파일 타임에 검증**할 수 있게 되었습니다.
//: 결과적으로 Swift Concurrency는 더 안전하고 예측 가능한 비동기 프로그래밍을 가능하게 합니다.


//: `Sendable` 프로토콜은 어떻게 데이터 경합의 가능성을 차단할 수 있을까요?
//: 데이터 경합(race condition)은 두 개 이상의 스레드가 동일한 가변(shared mutable) 상태에 동시에 접근하고,
//: 그 중 하나 이상이 해당 데이터를 수정하려 할 때 발생합니다.
//:
//: 특히 클래스와 같은 참조 타입은 여러 부분에서 동시에 접근되기 쉬우며,
//: 그로 인해 비동기 환경에서 데이터 경합이 발생할 가능성이 높습니다.
//: 이러한 문제를 방지하기 위해, Swift는 구조체(struct)나 열거형(enum)과 같은 **값 타입(value type)**의 사용을 권장합니다.
//:
//: 값 타입은 복사(copy) 기반으로 전달되기 때문에,
//: 어떤 스레드가 데이터를 수정하더라도 해당 변경이 다른 스레드에 영향을 미치지 않으며,
//: **국소적인 변경(local mutation)**만 발생하기 때문에 동시성 환경에서 훨씬 안전합니다.


//: 동시성 환경에서 안전한 프로그래밍을 보장하려면,
//: 값 타입과 같이 상태 변경이 국소적이며,
//: 혹은 내부 상태가 완전히 불변인 클래스만이 스레드 간에 안전하게 공유될 수 있습니다.
//:
//: 만약 이러한 안전한 타입에만 **특별한 표식**을 부여하고,
//: **서로 다른 스레드 간에는 이 표식을 가진 타입만 공유할 수 있도록 강제한다면 어떨까요?**
//: 바로 이 아이디어에서 출발해 등장한 것이 Swift의 `Sendable` 프로토콜입니다.


//: ### Sendable
//:
//: `Sendable` 프로토콜은 서로 다른 스레드 간에 **안전하게 전달될 수 있는 타입**을 나타내는 **마커 프로토콜(Marker Protocol)**입니다.
//: 이 프로토콜은 따로 요구하는 메서드나 프로퍼티가 없으며, 단지 해당 타입이 **동시성 환경에서도 안전하게 사용될 수 있다는 의미를 부여**합니다.
//:
//: 모든 타입은 이론적으로 `Sendable`을 준수할 수 있지만,
//: 실제로 값 타입인지, 또는 참조 타입이라면 내부 상태가 불변(immutable)인지 등에 따라 준수 조건이 달라집니다.
//: Swift 컴파일러는 이러한 조건을 분석하여, 타입이 `Sendable`을 안전하게 만족하는지를 컴파일 타임에 검증해 줍니다.


//: `Sendable` 프로토콜은 서로 다른 스레드에서 안전하게 공유될 수 있는 타입을 나타내는 마커 프로토콜(Marker Protocol)입니다.
//: 이 프로토콜은 이를 준수하는 타입에게 강제하는 아무런 요구사항이 없습니다.
//: 모든 타입이 `Sendable` 프로토콜을 준수할 수 있지만, 이 준수성을 만족하기 위한 조건이 조금씩 다릅니다.



//: #### Actor
//:
//: `actor`는 Swift Concurrency에서 도입된 특수한 참조 타입으로, 내부 상태를 **격리(isolated)**하여 **동시성 환경에서도 안전하게 데이터를 보호**할 수 있게 설계된 타입입니다.
//: 액터 타입은 기본적으로 `Sendable` 프로토콜을 준수합니다.

//: ---
//: ### 예제 1
actor ImageDownloader {
    private var cache: [URL: UIImage] = [:]
}
//: ---


//: #### 구조체
//:
//: Swift에서 값 타입은 기본적으로 높은 수준의 스레드 안전성을 제공합니다.
//: 값 타입을 다른 곳으로 전달하면 새로운 복사본이 생성되기 때문에,
//: 각 복사본은 서로 영향을 주지 않고 독립적으로 수정될 수 있습니다.
//:
//: 이러한 특성 덕분에 구조체(struct)나 열거형(enum)과 같은 값 타입은,
//: 모든 내부 상태가 `Sendable`을 준수하는 한, 기본적으로 `Sendable`로 간주됩니다.

//: ---
//: ### 예제 2
struct Dog {
    var name: String = "Whitey"
    var age: Int
}
//: ---

//: 하지만 구조체 내부에 하나라도 `Sendable`을 준수하지 않는 프로퍼티가 있다면,
//: 해당 구조체 전체는 `Sendable`을 만족할 수 없습니다.
//: 즉, 값 타입이라 하더라도 내부에 비동기 환경에서 안전하지 않은 참조 타입이 포함되어 있다면,
//: 해당 타입은 서로 다른 스레드 간에 안전하게 공유될 수 없으며, **데이터 경합의 원인이 될 수 있습니다.**

//: ---
//: ### 예제 3
class Font { }

struct Label: Sendable {
    var text: String?
    var font: Font // 🟡 오류: 'Font'는 'Sendable'을 준수하지 않음
}
//: ---


//: #### 클래스
//:
//: 대부분의 클래스는 `Sendable`을 자동으로 만족하지 않습니다.
//: 단, 아주 제한적인 조건을 만족하는 경우에 한해 직접 `Sendable`을 명시적으로 채택할 수 있습니다.
//:
//: 구조체와는 달리, 클래스는 아무리 조건을 만족하더라도 Swift 컴파일러가 암시적으로 `Sendable` 준수성을 추가해주지 않으며,
//: 반드시 **개발자가 명시적으로 `Sendable`을 선언**해야 합니다.
//:
//: 클래스가 `Sendable`을 준수하려면 다음 조건을 모두 만족해야 합니다:
//: - 클래스는 반드시 `final`이어야 하며,
//: - 모든 저장 프로퍼티는 `Sendable` 타입이어야 하고,
//: - 그 값들은 **불변(immutable)**이여야 합니다.
//:
//: 이 조건을 만족하면, 해당 클래스 인스턴스는 동시성 환경에서도 안전하게 공유될 수 있습니다.

//: ---
//: ### 예제 4
struct Tag: Sendable { }

final class Post: Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    let tag: [Tag] = []
    init() {
        userId = 0
        id = 0
        title = ""
        body = ""
    }
}

//: 클래스에 `final` 키워드를 사용해 상속을 제한하는 이유는
//: 만약 해당 클래스를 다른 곳에서 상속받아 새로운 기능이나 프로퍼티가 추가되면,
//: 원래의 `Sendable` 조건을 더 이상 만족하지 않을 수 있기 때문입니다.
//:
//: 즉, 상속을 허용하면 해당 타입의 **스레드 안전성 보장을 컴파일 타임에 예측할 수 없게 되므로,**
//: `Sendable`을 안전하게 보장하려면 **상속이 불가능한 `final` 클래스여야만** 합니다.



//: ### @unchecked Sendable
//:
//: `Sendable` 앞에 `@unchecked`를 붙이면 다음과 같은 의미를 갖습니다:
//: **"이 타입은 `Sendable`을 채택하지만, 컴파일러가 준수 조건을 검사하지 않아도 괜찮아.**
//: **나는(개발자) 이 타입이 스레드 안전하다는 걸 보장할 수 있어."**
//:
//: 이 키워드는 주로 `NSLock`, `DispatchSemaphore`, **직렬 디스패치 큐** 등을 사용해
//: 내부 동기화(synchronization)를 직접 구현한 타입에 사용됩니다.
//: 개발자가 직접 적절한 동기화 매커니즘을 제공하고 있다고 판단되는 경우,
//: 컴파일러의 검사 없이도 `Sendable`을 선언할 수 있게 해줍니다.
//:
//: 단, 컴파일러가 검사를 수행하지 않기 때문에,
//: `@unchecked Sendable`은 **개발자 책임 하에 사용**해야 하며,
//: 부주의할 경우 데이터 경합이나 동시성 오류를 유발할 수 있습니다.

//: ---
//: ### 예제 5
final class Todo: @unchecked Sendable {
    var isChecked: Bool = false
    let lock = NSLock()
    
    func toggleChecked() {
        lock.lock()   // 🔒
        isChecked.toggle()
        lock.unlock() // 🔓
    }
}
//: ---




//: ### @Sendable
//:
//: Swift에서는 함수(특히 클로저)도 `Sendable`하게 만들 수 있습니다.
//: 하지만 클로저는 일반 타입처럼 `Sendable` 프로토콜을 직접 채택할 수 없기 때문에,
//: 대신 `@Sendable`이라는 특별한 속성(Attribute)을 사용해 선언합니다.
//:
//: `@Sendable` 클로저는 **다른 스레드에 안전하게 전달될 수 있어야 하므로**,
//: 클로저 내부에서 캡처하는 모든 값은 반드시 **불변(immutable)**이며, **`Sendable`을 준수하는 타입**이어야 합니다.
//: 즉, `@Sendable` 클로저는 **가변 지역 변수**를 캡처할 수 없습니다.
//: 이 제약은 클로저가 **`Sendable`하지 않은 상태를 액터 경계(actor boundary)를 넘어서 이동시키는 것을 방지**합니다.

//: ---
//: ### 예제 6
@MainActor var mutableValue = 30
@MainActor let immutableValue = 10

let sendableClosure = { @Sendable () -> Void in
//    print("➡️ @Sendable 클로저는 가변 상태를 캡처(Capture)할 수 없습니다. \(mutableValue)")
    print("➡️ @Sendable 클로저는 `Sendable`한 불변 상태만 캡처할 수 있습니다. \(immutableValue)")
}
Task { sendableClosure() }
//: ---

//: `@Sendable` 클로저는 액터 경계를 넘어서 실행될 수 있기 때문에,
//: Swift는 해당 클로저를 **자체적으로 격리된(isolated)** 실행 단위로 간주합니다.
//:
//: 즉, `@MainActor`에 격리된 클래스 내부에서 정의한 `@Sendable` 클로저라 하더라도,
//: 해당 클로저는 **MainActor에 격리되는 게 아닙니다.**
//: 이는 `@Sendable` 클로저가 메인 액터 외부에서 실행될 수도 있기 때문에,
//: 내부적으로 **액터 컨텍스트를 포함하지 않고**, 완전히 **분리된 독립적 실행 컨텍스트**로 취급되기 때문입니다.
//:
//: 따라서 `@Sendable` 클로저 안에서는 `@MainActor`에 격리된 멤버에 직접 접근할 수 없습니다.

//: ---
//: ### 예제 7
@MainActor class Counter {
    var counter: Int = 0
    var closure: (@Sendable (Int) -> Void)?
    func setupClosure() {
        self.closure = { [weak self] value in
//            self?.counter = value // 🔴 메인 액터에 격리된 `counter` 프로퍼티는 `@Sendable` 클로저에서 수정할 수 없음
        }
    }
}
//: ---

//: 아울러, 액터 외부에서 실행될 수 있는 **동기적인 `@Sendable` 클로저는 액터 내부 상태를 캡처할 수 없습니다.**
//: 이는 액터와의 상호작용이 항상 **비동기적으로 이루어져야 한다는 원칙**에 기반한 제한입니다.

//: 오직, **비동기적인 `@Sendable` 클로저만이 액터 내부 상태를 캡처할 수 있습니다.**

//: ---
//: ### 예제 8
actor ImageCacher {
    var cache: [String: UIImage] = [
        "https://example.com/image1.png": UIImage(),
        "https://example.com/image2.png": UIImage()
    ]
    var onDeleteImageCache: (@Sendable () async -> Void)?
    
    func setup() {
        self.onDeleteImageCache = { [weak self] in
            guard let self = self else { return }
            for (url, _) in await self.cache {
                print("🧹 삭제 예정 이미지 URL: \(url)")
            }
        }
    }
    func deleteImageCache() async {
        await onDeleteImageCache?()
        cache.removeAll()
    }
}

let cacher = ImageCacher()

Task {
    await cacher.setup()
    await cacher.deleteImageCache()
    // await cacher.onDeleteImageCache?()
}
//: ---



//: 지금까지 우리가 살펴본 수많은 `Swift Concurrency` 예제는 사실상 모두 `@Sendable`에 의존하고 있었습니다.
//: 특히 `Task`나 `TaskGroup`의 `addTask` 메서드에서 수행할 작업을 정의할 때,
//: **모두 `@Sendable` 클로저를 요구**합니다.
//:
//: 예를 들어, 아래는 `Task`와 `TaskGroup`의 정의 중 일부입니다:
//:
//: ```swift
//: Task.init(priority: TaskPriority? = nil, operation: @Sendable @escaping @isolated(any) () async -> Success)
//: ```
//:
//: ```swift
//: mutating func addTask(
//:     executorPreference taskExecutor: (any TaskExecutor)?,
//:     priority: TaskPriority? = nil,
//:     operation: @Sendable @escaping @isolated(any) () async -> ChildTaskResult
//: )
//: ```
//:
//: 이러한 클로저에 `@Sendable`이 필요한 이유는,
//: **해당 작업이 실행될 위치(스레드나 Task 컨텍스트)가 명확하지 않기 때문에,** 클로저가 **스레드 간에 안전하게 전달될 수 있어야 하기 때문입니다.**
//:
//: > 💡 참고: Swift 6.0부터는 `@Sendable` 키워드가 `sending`으로 변경되었습니다.











//: ---
//: [부록] 각 타입에서의 `Sendable` 프로토콜 준수 조건
//: ---

//: ---------------------------------------------------------------------------------------------------------------------------------------------
//: | 타입                | 준수 조건                                                                  | 비고                                        |
//: ---------------------------------------------------------------------------------------------------------------------------------------------
//: | **구조체 (Struct)**  | - 모든 저장 프로퍼티가 `Sendable`일 경우 암시적으로 `Sendable` 채택                 |                                            |
//: | **열거형 (Enum)**    | - 모든 연관값(Associated Value)이 `Sendable`일 경우 암시적으로 `Sendable` 채택    |                                            |
//: | **클래스 (Class)**   | - `final` 클래스여야 하며, 모든 멤버가 불변 또는 동기화 메커니즘으로 보호되어야 함         | 컴파일러 검사 생략 시 `@unchecked Sendable` 필요  |
//: | **클로저 (Closure)** | - 캡처한 모든 값이 `Sendable`이어야 하며, **가변 상태는 캡처 불가**                  | `@Sendable` 키워드 필요                       |
//: ---------------------------------------------------------------------------------------------------------------------------------------------

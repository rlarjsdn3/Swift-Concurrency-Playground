import UIKit

//: ---
//: # Sendable
//: ## 서로 다른 비동기 컨텍스트에서 안전하게 공유될 수 있는 타입
//: ---

//: ### ddd
//:
//* Swift Concurrency가 해결하고자 하는 목표 설명 - 컴파일러가 데이터 경합이 발생했다는 사실을 알려주지 않을 뿐더러, 디버그가 하기가 매우 어렵다. 컴파일 과정에서 스레드에 안전하지 않은 - 데이터 경합을 유발할 가능성이 높은 - 코드를 컴파일러가 검사해 보다 안전한 코드를 작성하는 게 목표임
//
//* 어떻게 데이터 경합을 막을 수 있을까? 데이터 경합은 두 개 이상의 스레드가 공유된 가변 상태에 동시에 접근하고, 적어도 하나 이상의 스레드가 쓰기 작업을 수행할 때 발생함.
//
//* 즉, 클래스와 같은 참조 타입이 코드의 여러 부분에서 동시에 접근해서 수정하려고 할 때 데이터 경합이 발생할 수 있음. 이를 방지하려면 구조체나 열거형과 같은 값 타입을 사용하면 데이터 경합의 가능성이 줄어듬
//
//* 예를 들어, _array1_을 _array2_에 할당한 후, 각 배열에 서로 다른 값을 동시에 추가하더라도, 각 배열을 서로 영향을 주지 않음
//
//```swift
//var array1 = [1, 2]
//var array2 = array1
//
//array1.append(3)
//array2.append(4)
//
//print(array1) // [1, 2, 3]
//print(array2) // [1, 2, 4]
//```
//
//* 즉, 값 타입을 사용하면 서로 다른 코드 부분에서 서로 영향을 주지 않아 데이터 경합이 일어날 수 없음. (과거부터 애플은 가능하면 구조체 타입을 사용하라고 권장해왔음. [여기]()참조)
//
//* In Swift, value types provide a lot of thread safety out of the box. When you pass a value type from one place to the next, a copy is created which means that each place that holds a copy of your value type can freely mutate its copy without affecting other parts of the code.
//
//
//* 이런 아이디어에서 출발해 등장한 프로토콜이 바로 Sendable임. Swift는 Sendable이라는 새로운 마커 프로토콜을 도입하고, 이를 통해 컴파일 단계에서 잠재적으로 스레드에 안전하지 않은 코드를 막을 수 있음
//
//## Sendable
//
//* Sendable 프로토콜은 서로 다른 동시성 컨텍스트(concurrent context) 간 값을 전달할 수 있는 타입임. Sendable은 아무런 요구사항이 없음
//
//* Sendable은 액터, 구조체, 클래스 등 여러 타입에서 준수하게 만들 수 있으며, 각 타입마다 Sendable 요구사항이 조금씩 다름.
//
//### 액터
//
//* 액터는 기본적으로 Sendable을 준수함.
//
//* 다만, 액터가 다른 프로토콜을 준수하는 경우, 해당 프로토콜이 Sendable을 준수해야 함.
//
//```swift
//protocol ImageDownloader: Sendable { ... }
//
//actor DefaultImageDownloader: ImageDownloader { ... }
//```
//
//### 구조체
//
//* In Swift, value types provide a lot of thread safety out of the box. When you pass a value type from one place to the next, a copy is created which means that each place that holds a copy of your value type can freely mutate its copy without affecting other parts of the code.
//
//* Because of this behavior, value types like structs and enums are Sendable by default as long as all of their members are also Sendable.
//
//```swift
//struct Dog {
//    var name = "Whitey"
//    var age = 1
//}
//```
//
//* 위 구조체는 Sendable 프로토콜을 준수함. Swift 컴파일러는 구조체 내부의 모든 프로퍼티가 Sendable 프로토콜을 준수하는 타입이라면 자동으로 구조체에 Sendable 프로토콜 준수성을 추가함
//
//```swift
//class Font { ... }
//
//struct Text {
//    var title: String
//    var font: Font = .headline
//}
//```
//
//* 반면, 위 구조체는 Sendable 프로토콜을 준수하지 못함. 왜냐하면 _font_ 프로퍼티의 타입이 Sendable 프로토콜을 준수하지 않기 때문임.
//
//
//### 클래스
//
//* 클래스는 기본적으로 Sendable 프로토콜을 준수할 수 없지만, 극히 제한적인 상황에서는 준수성을 추가할 수 있음. 그리고 구조체와 달리, 조건을 만족한다 하더라도 자동으로 Sendable 준수성을 추가하지 않음. 직접 해당 클래스가 Sendable 프로토콜을 준수한다고 작성해야 함
//
//```swift
//class ImageDownloader: Sendable {
//}
//```
//
//* 클래스가 final 클래스이고, 내부 프로퍼티가 모두 불변(immuatable)이면 Sendable 프로토콜을 준수할 수 있음
//
//* 클래스에 상속을 허용하게 되면, 하위 클래스에서 기능을 재정의하거나 추가하는 과정에서 Sendable 준수를 위한 조건을 만족하지 못할 수 있기 때문에 허용하지 않음
//
//* 아울러, 구조체와 마찬가지로 내부 프로퍼티가 모두 Sendalbe 프로토콜을 준수한다면 클래스도 Sendable이 될 수 있음
//
//#### @unchecked Sendable
//
//* @unchecked Sendable은 해당 클래스가 Sendable하다는 걸 개발자가 보장하며, 컴파일러가 검사하지 말라는 의미임.
//
//* 일반적으로 클래스에 락, 직렬 디스패치 큐나 디스패치 세마포어 등 동기화 매커니즘을 자체적으로 제공하고 있으며, 데이터 경합이 발생하지 않을거라 확신할 수 있을 때만 해당 키워드를 사용해야 함.
//
//* 그리고 모듈(타겟) 내 모든 코드를 일괄적으로 Swift Concurrency에 맞게 변환하는 건 불가능함. 점진적으로 Swift concurrency를 도입하고자 하는 목적으로도 해당 키워드를 사용할 수 있음
//
//```swift
//final class ImageDownloader: @unchecked Sendable {
//
//}
//```
//
//
//## @Sendable
//
//* 클로저는 서로 다른 동시성 경계를 넘나들어 실행될 수 있기 때문에, - (내용 보충) - 잘못된 클로저의 사용은 데이터 경합으로 쉽게 이어질 수 있음.
//-> 동시성 경계를 넘나든다 -> 이 말 보충
//
//* 따라서 함수도 Sendable하게 만들어야 함. 함수(클로저)도 Sendable이 될 수 있음. 다만, 함수는 프로토콜을 준수하지 못하기 때문에 @escaping처럼 속성 형태로 해당 기능을 제공함.
//
//```swift
//
//```
//
//* 클로저 선언 시, 매개변수 앞에 @Sendable 키워드를 붙이면 해당 클로저는 Sendable하게 됨. 클로저가 Sendable하다는 의미는 해당 클로저가 캡처하는 모든 값들은 Sendable 프로토콜을 준수해야 한다는 의미임.
//
//```swift
//
//```
//
//* 실제로 Task의 operation 클로저를 살펴보면 @Sendable 속성을 가진다는 걸 볼 수 있음. 즉, operation 클로저에서 캡처하는 모든 값은 Sendable이어야 한다는 뜻임.
//
//
//### Sending
//
//* Swift 6.0부터 sending 키워드가 새롭게 도입됨. sending 키워드는 @Sendable 키워드와 기능이 비슷하지만, 캡처가 일어난 후에도 값이 바뀔 가능성이 없다면, Sendable하지 않더라도 해당 클로저 내에서 값을 조정할 수 있다는 튿징이 있음
//
//```swift
//func doTask(closure: @Sendable () async -> Void) {
//    closure()
//}
//
//Task {
//    await doTask {
//        counter.value += 1 // 🔴
//    }
//}
//```
//
//* 위 doTask 메서드는 @Sendable 속성의 클로저를 매개변수로 받음. 그리고 해당 클로저 내부에서 counter 값을 1 증가시키고 있음. 하지만 counter는 Sendable하지 않기 때문에 당연 오류가 발생함.
//
//```swift
//func doTask(closure: sending () async -> Void) {
//    closure()
//}
//
//Task {
//    await doTask {
//        counter.value += 1 // 🔵
//    }
//    // counter.value += 1 // 🟡 doTask 이후에 값이 바뀐다면 에러가 발생
//}
//```
//
//* 하지만, sending 키워드를 사용해 클로저를 받는다면, 위 코드는 에러가 발생하지 않음. 다만, sending 클로저 이후에 값을 변경하려고 시도하면(주석을 해제하면) 오류가 발생함. 이렇듯 sending 키워드는 데이터 경합이 발생하지 않을 가능성이 높은 코드에 한해서 Sendable하지 않은 값이라도 해당 클로저 내부에서 값을 변경할 수 있도록 허용함.
//
//* 왜 이 키워드가 생겨나게 되었는가? -> 내용 보충
//
//```swift
//Task.init()
//```
//
//* Swift 6로 넘어오면서 Task, Continuation 등 많은 객체가 @Sendable에서 sending으로 키워드가 바뀜
//
//
//
//## 정리
//
//* Sendable 정의
//
//* 액터 /구조체 / 클래스에서 Sendable
//
//* @Sendable 클로저
//
//* Sendable이 준수될 수 있는 예 표로 정리

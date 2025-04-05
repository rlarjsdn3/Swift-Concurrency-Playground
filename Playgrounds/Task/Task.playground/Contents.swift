import UIKit

//: ---
//: # Task
//: ## 비동기 작업의 기본 단위
//: ---
//: `Task`는 비동기 작업의 기본 단위이며, 비동기 코드는 모두 `Task` 내부에서 실행됩니다. 각 `Task`는 **독립적인 실행 컨텍스트**를 가집니다.
//: 각 `Task`는 `취소 전파`, `액터`, `Task-Local 변수` 등 자체적인 자원을 가집니다.
//:
//: `Task` 내부의 코드는 `디스패치 큐`와 마찬가지로 순차적으로 실행됩니다.
//: 서로 다른 `Task`는 **병렬**로 실행됩니다. 즉, 서로 다른 `Task`는 상태 공유 없이 독립적으로 작동합니다. 비동기(async) 함수는 `Task` 내부에서만 호출이 가능합니다.
//:
//: 즉, `Task`는 **비동기 함수를 실행할 수 있는 컨텍스트를 생성**하는 역할을 합니다.
//: `Task`는 동기 컨텍스트(클로저)에서 비동기 함수를 호출하도록 도와주는 가교 역할을 합니다.

//: `Task`는 구조화되지 않은 동시성(Unstructured Concurrency)입니다.
//: 구조화되지 않은 동시성은 구조화된 동시성(Structured Concurrency)보다 높은 유연성을 부여하지만, `취소 전파` 등 자체적인 자원을 상속하는 데 제한이 따릅니다. (자세한 내용은 부록을 참조하세요.)

//: ---
//: ### 예제 1
Task {
    try? await Task.sleep(for: .seconds(1))
    print("✅ 작업 1 실행 시작")
    print("✅ 작업 1 실행 종료")
}
print("▶️ `Task`는 비동기 작업의 기본 단위입니다.")
// Print "▶️ `Task`는 비동기 작업의 기본 단위입니다."
// Print "✅ 작업 1 실행 시작"
// Print "✅ 작업 1 실행 종료"
//: ---

//: `Task`는 작업을 생성하자마자 곧바로 실행되며, 해당 작업 객체를 변수에 담을 수도 있습니다.
//: 작업 객체를 변수에 담지 않더라도, 해당 작업은 정상적으로 실행됩니다. 하지만, `취소 전파` 및 `예외 처리`를 할 수 없게 됩니다.
//:
//: 아울러, `Task`는 비동기적이라는 사실을 기억해주세요.
//: `Task`가 실행되면 해당 작업이 끝나기까지 기다리지 않고, 곧바로 다음 줄의 코드가 실행됩니다.

//: ---
//: ### 예제 2
let task1: Task<Void, Never> = Task {
    // try? await Task.sleep(for: .second(1))
    print("✅ 작업 2 실행 시작")
    print("✅ 작업 2 실행 종료")
}
task1.cancel()
print("▶️ `Task` 객체를 변수에 담으면 작업을 취소하거나 예외 처리를 할 수 있습니다.")
// Print "▶️ `Task` 객체를 변수에 담으면 작업을 취소하거나 예외 처리를 할 수 있습니다."
// Print "✅ 작업 2 실행 시작"
// Print "✅ 작업 2 실행 종료"
//: ---

//: 하지만, 작업을 취소하더라도 해당 작업이 즉시 중단되는 것은 아닙니다.
//: 단지 `Task.isCancelled` 값이 `true`로 설정될 뿐입니다.
//:
//: 따라서 각 작업은 실행 중간중간 **취소 여부를 스스로 확인하고**, 적절한 방식으로 작업을 중단해야 합니다.
//: 이러한 방식을 **협력적 취소(Cooperative Cancellation)** 라고 합니다.
//:
//: 협력적 취소가 필요한 이유는 작업마다 취소에 대응하는 방식이 다를 수 있기 때문입니다.
//: 대부분의 작업은 취소 전파를 받으면 예외를 던지며 종료되지만,
//: 일부 작업은 지금까지의 중간 결과를 반환하거나, 별도의 정리 작업을 수행할 수도 있습니다.

//: 이 외에도 `Task`는 값을 반환할 수 있습니다.
//: 단, 반환하는 값은 반드시 `Sendable` 프로토콜을 준수해야 합니다.
//:
//: ---
//: ### 예제 3
Task {
    let task2: Task<Int, Never> = Task {
        await doSomething()
    }
    let birthDay = await task2.value
    print("🩵 김소월의 생일은 \(birthDay)입니다.")
}
// Print "🩵 김소월의 생일은 19980321입니다."
//: ---

//: `GCD`와 마찬가지로 `Task`에도 우선순위(priority)를 설정할 수 있습니다.
//: 사용 가능한 우선순위는 `userInitiated`, `high`, `medium`, `low`, `utility`, `background` 등이 있습니다.
//:
//: 하지만 `Task`는 `GCD`와 달리 **큐(queue)** 기반이 아니기 때문에,
//: `GCD`에서 종종 발생하는 **우선순위 역전(priority inversion)** 문제가 발생하지 않습니다.
//:
//: ---
//: ### 예제 4
Task(priority: .userInitiated) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}

Task(priority: .high) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}

Task(priority: .medium) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}

Task(priority: .low) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}

Task(priority: .utility) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}

Task(priority: .background) {
    print("📺 \(Task.currentPriority) 우선순위로 설정된 작업")
}
//: ---

//: `Task`는 `취소 전파`, `액터`, `Task-Local 변수` 등 다양한 자체적인 자원을 갖습니다.
//: 이 중 `액터`, `Task-Local 변수`, `우선순위`는 새로운 `Task`를 생성할 때 **상속**될 수 있습니다.

//: ---
//: ### 예제 5
let task3 = Task(priority: .userInitiated) {
    print("😃 Task3의 작업 우선순위: \(Task.currentPriority)")
    
    let task4 = Task {
        print("😃 Task4의 작업 우선순위: \(Task.currentPriority)")
    }
}
// Print "😃 Task3의 작업 우선순위: TaskPriority.high"
// Print "😃 Task4의 작업 우선순위: TaskPriority.high"
//: ---

//: 위 예제에서 `task3`은 `userInitiated` 우선순위로 생성된 작업입니다.
//: 그 내부에서 생성된 `task4`는 별도의 우선순위를 지정하지 않았지만,
//: 바깥 작업의 우선순위를 상속받아 동일한 우선순위(`.high`)로 실행됩니다.


//: 마찬가지로 `Task`와 같은 **구조화되지 않은 동시성**에서는
//: `취소 전파`가 일어나지 않습니다.
//:
//: 즉, 바깥쪽 작업이 취소되더라도 내부 작업에는 **취소가 전달되지 않습니다**.
//:
//: ---
//: ### 예제 6
let task5 = Task {
    print("🫤 Task5의 작업이 취소되었을까요?: \(Task.isCancelled)")
    
    let task6 = Task {
        print("🫤 Task6의 작업이 취소되었을까요?: \(Task.isCancelled)")
    }
}
task5.cancel()
print("➡️ Task5가 취소되더라도, Task6에게 취소가 전파되지 않아요.")
//: ---


//: 이쯤 되면 이런 궁금증이 생길 수도 있습니다.
//: "Task 클로저에서 `[weak self]` 같은 약한 캡처가 꼭 필요한 걸까?" 🤔
//:
//: 결론부터 말하면, **대부분의 경우 필요 없습니다.**
//:
//: `Task`의 `operation` 클로저는 해당 작업이 완료되면 자동으로 메모리에서 해제됩니다.
//: 즉, `Task` 객체를 변수에 할당하더라도 **작업이 끝나면 클로저는 해제**되기 때문에,
//: 순환 참조가 생기더라도 그 시간은 아주 짧고, 문제가 되지 않습니다.
//:
//: 따라서 일반적인 상황에서는 `[weak self]`를 명시적으로 사용할 필요가 없습니다.

//: ---
//: ### 예제 7
struct Work: Sendable { }

actor Worker {
    var work: Task<Void, Never>?
    var result: Work?
    
    deinit {
        // even though the task is still retained,
        // once it completes it no lognre causes a reference cycle with the actor
        
        print("deinit actor")
    }
    
    func start() {
        work = Task {
            print("start task work")
            try? await Task.sleep(for: .seconds(3))
            self.result = Work()
            print("completed task work")
            // but as the task completes, this reference is released
        }
        // we keep a strong reference to the task
    }
}
Task { await Worker().start() }
//: ---





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

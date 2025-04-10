## Actor
**특정 작업 컨텍스트 내에 바인딩하고 읽을 수 있는 값**

---

```swift
import UIKit
import _Concurrency
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class CustomExecutor: SerialExecutor {
    let label: String
    private let queue: DispatchQueue
    
    init(label: String = "com.serial.queue") {
        self.label = label
        self.queue = DispatchQueue(label: label)
    }
    
    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let unownedExecutor = asUnownedSerialExecutor()
        queue.async {
            unownedJob.runSynchronously(on: unownedExecutor)
        }
    }
    
    var asUnownedSerialExecutor: UnownedSerialExecutor {
        return UnownedSerialExecutor(ordinary: self)
    }
}

actor Counter {
    private var value = 0
    
    private let executor: (any SerialExecutor)
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        self.executor.asUnownedSerialExecutor()
    }
    
    init(executor: any SerialExecutor = CustomExecutor()) {
        self.executor = executor
    }
    
    func increment(by amount: Int) {
        value += amount
//        print("[\(Thread.current)] Incremented by \(amount), value: \(value)")
    }
    
    func getValue() -> Int {
        return value
    }
}

let counter = Counter()

final class CustomTaskExecutor: TaskExecutor {
    let label: String
    private let queue: DispatchQueue
    
    init(label: String = "com.serial.queue") {
        self.label = label
        self.queue = DispatchQueue(label: label)
    }
    
    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let unownedExecutor = asUnownedTaskExecutor()
        queue.async {
            unownedJob.runSynchronously(on: unownedExecutor)
        }
    }
    
    func asUnownedTaskExecutor() -> UnownedTaskExecutor {
        return UnownedTaskExecutor(ordinary: self)
    }
}

Task(executorPreference: CustomTaskExecutor()) { @MainActor in
    await withDiscardingTaskGroup { group in
        for i in 1...100 {
            group.addTask {
                await counter.increment(by: 1)
            }
        }    
    }
    print("[\(Thread.current)]")
    print("Final counter value: \(await counter.getValue())")
}

```


Task의 선호 실행자를 비동기 직렬 큐로 구성된 CustomTaskExecutor()로 하고, 해당 작업을 @MainActor에 격리시킨다면 무슨 일이 일어날까?




```swift

@globalActor
actor CustomActor {
    static let shared = CustomActor()
    
    let executor = CustomExecutor()
    
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        return executor.asUnownedSerialExecutor()
    }
}


Task { @CustomActor in
    await withDiscardingTaskGroup { group in
        for i in 1...100 {
            group.addTask {
                await counter.increment(by: 1)
            }
        }
    }
    print("[\(Thread.current)]")
    print("Final counter value: \(await counter.getValue())")
}


```

글로벌 액터를 통해서 해당 액터가 어느 실행자(비동기 직렬 큐)로 코드를 실행할지 결정하고

Task를 @CustomActor로 격리시키면, Task내 코드들이 비동기 직렬 큐에 삽입되어 처리됨





Swift에서 actor로 격리한다는 것은,
특정 데이터에 대한 접근을 오직 해당 actor 내에서만 허용함으로써,
동시에 접근하지 못하게 보호하는 것을 의미합니다.

동시에, actor는 자신이 사용하는 **실행자(Executor)**를 통해
어떤 스레드에서, 어떤 방식(예: 직렬 실행 등)으로 작업이 처리될지를 결정합니다.

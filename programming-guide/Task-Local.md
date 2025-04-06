## Task-Local
**특정 작업 컨텍스트 내에 바인딩하고 읽을 수 있는 값**

---

`Task-Local`은 특정 작업(Task) 컨텍스트 내에서 바인딩하고 읽을 수 있는 값을 정의할 수 있는 기능입니다.

이 값은 **명시적으로 전달하지 않더라도**, 바인딩 범위 내에서 생성된 작업이 있다면 **해당 작업과 그 작업의 하위(안쪽) 작업까지 `Task-Local` 값을 자동으로 상속**받습니다. 따라서 특정 작업 범위 내에서만 사용할 **제한적인 컨텍스트 값**이 필요할 때 유용하게 사용할 수 있습니다. 

`Task-Local` 값은 **정적(static) 프로퍼티 또는 전역 변수**로 선언되어야 하며, `@TaskLocal` 매크로를 붙여 정의합니다.

```swift
enum Example {
    @TaskLocal
    static var traceID: String?
}

// Global task local properties are supported since Swift 6.0:
@TaskLocal
var contextualNumber: Int = 12
```

`Task-Local` 변수는 반드시 **기본 값(default value)**을 가져야 합니다. 만약 해당 변수의 타입이 옵셔널(Optional)이라면, 기본 값으로는 `nil`이 사용됩니다.

이 기본 값은 현재 코드가 동기 함수처럼 **작업 컨텍스트 외부에서 실행되고 있는 경우** 또는 현재 작업 범위에서 **해당  `Task-Local` 값을 바인딩하지 않고 사용할 경우** 활용됩니다. 즉, `Task-Local` 값은 **특정 작업 컨텍스트에서 바인딩되어 있어야만 유효하며,** 그렇지 않으면 항상 기본 값을 사용하게 됩니다.


`Task-Local` 값은 동기 함수와 비동기 함수 모두에서 읽을 수 있으며, 읽을 때는 일반적인 정적 프로퍼티처럼 간단하게 접근할 수 있습니다.

```swift
if let traceID = Example.traceID {
    print("➡️ Task-Local의 값은 \(traceID)입니다.")
} else {
    print("trace ID가 설정되지 않았습니다.")
}
```

`Task-Local` 값은 일반 변수처럼 직접 할당할 수 없습니다. 대신, **`$traceID.withValue(_:) { ... }`** 메서드를 사용해 특정 범위 내에서 바인딩해야 합니다.

값은 해당 클로저의 **실행 범위 동안에만 유효**하며, 해당 범위에서 생성된 모든 하위 작업은 이 값을 **자동으로 상속받습니다.** 단, `DetachedTask`는 `Task-Local` 값을 상속하지 않습니다. 반면, 일반 `Task`는 **구조화된 동시성 여부와 관계없이**, `Task-Local` 값을 복사(copy)하는 방식으로 자식 작업에 값을 전파합니다.


```swift
func read() -> String {
    if let value = Example.traceID {
        "\(value)"
    } else {
        "<no value>"
    }
}

func doSomething() async {
    await Example.$traceID.withValue("1234") { 
        print("traceID: \(Example.traceID)") // Print "traceID: 1234"
        
        async let id = read() // async let child task, traceID: 1234
        
        await withTaskGroup(of: String.self) { group in
            group.addTask { read() }
            return await group.next()! // task group child task, traceID: 1234
        }
        
        Task { // unstructured tasks do inherit task locals by copying
            read() // traceID: 1234
        }
        
        Task.detached { // detached tasks do not inherit task-local values
            read() // traceID: nil
        }
    }
    
    Task { 
        read() // traceID: nil
    }
}
Task { await doSomething() }
```

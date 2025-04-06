## Cancellation
**구조화된 동시성에서 작업 취소를 전파하는 방법**

---

###  개요

작업의 취소는 단순히 리소스를 효율적으로 관리하는 것에 그치지 않고, 명확하고 예측 가능한 흐름을 유지하며, 우수한 사용자 경험(UX)을 제공하기 위해 필수적인 기능입니다.

예를 들어, 우리가 사진첩 앱을 스크롤한다고 가정해봅시다. 스크롤을 하면서 화면에 보이는 셀에 해당하는 이미지를 네트워크를 통해 불러오게 됩니다. 그런데 사용자가 빠르게 스크롤하여 해당 셀이 화면에서 사라지면, 아직 로딩 중인 이미지 작업은 더 이상 필요하지 않게 되죠. 이런 상황에서 여전히 보이지 않는 셀을 위한 네트워크 요청을 계속 유지하는 것은 비효율적이며, 시스템 리소스를 낭비하게 됩니다.

Swift Concurrency가 도입되기 전까지는 이러한 비동기 작업을 안전하고 구조적으로 취소하기가 까다로웠습니다.

예를 들어 `DispatchQueue`를 사용할 경우, `DispatchWorkItem`을 생성해 `cancel()`을 호출함으로써 작업을 취소할 수는 있었지만, 
* 취소 상태의 전파가 어렵고,
* 중첩 작업이나 비동기 체인의 관리가 힘들며,
* `isCancelled` 플래그를 사용할 경우에도 스레드 안전성을 따로 고려해야 했습니다.

이런 한계를 보완하기 위해 `OperationQueue`를 사용하는 방법도 있었지만, 구현이 복잡하고 코드 양이 많아지는 단점이 있었습니다.

```swift
var isCancelled = false

DispatchQueue.global().async {
    for i in 0..<100 {
        if isCancelled { return }
        print(i)
    }
}
```

Swift Concurrency는 보다 구조화되고 쉬운 방식으로 작업의 취소 유무를 확인하고, 필요한 경우 예외 처리를 할 수 있는 API를 제공합니다. Swift Concurrency는 협력적 취소 모델(Cooperative Cancellation Model)을 채택합니다. 각 작업은 실행 단계에서 적절한 시점마다 작업의 취소 유무를 확인하고 작업 취소에 적절히 처리를 해주어야 합니다. 즉, 상위 작업이 하위 작업에게 작업 취소를 전파했다고 해서 하위 작업은 곧바로 작업을 종료하는 것이 아닙니다. 이는 각 작업마다 취소를 처리하는 방법이 다를 수 있기 때문입니다. 작업은 본인만의 적절한 방식으로 취소를 처리해야 하며, 취소가 완료되면 지금까지 한 작업을 반환하거나 아니면 아예 예외를 던질 수 있습니다. 

각 작업에서 `Task.isCancelled`나 `Task.checkCancellation()` 정적 프로퍼티/메서드를 호출해 작업의 취소 유무를 확인할 수 있습니다. 작업의 취소되면 `Task.isCancelled`는 `true`를 반환하며, `Task.checkCancellation()`은 `CancellationError` 예외를 던집니다. 일반적으로 작업 취소가 감지되어 별도 처리를 해주어야 한다면 `Task.isCancelled`를 사용하고, 곧바로 예외를 던진다면 `Task.checkCancellation()`을 사용합니다.



### 구조화된 동시성(Structured Concurrency)

#### 동시적 바인딩(async-let)


#### 작업 그룹(Task Group)



### 구조화되지 않은 동시성(Unstructured Concurrency)




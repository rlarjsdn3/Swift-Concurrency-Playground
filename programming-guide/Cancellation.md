 ## Cancellation
**구조화된 동시성에서 작업 취소를 전파하는 방법**

---

###  개요

작업의 취소는 단순히 리소스를 효율적으로 관리하는 것에 그치지 않고, 명확하고 예측 가능한 흐름을 유지하며, 우수한 사용자 경험(UX)을 제공하기 위해 필수적인 기능입니다.

예를 들어, 우리가 사진첩 앱을 스크롤한다고 가정해봅시다. 스크롤을 하면서 화면에 보이는 셀에 해당하는 이미지를 네트워크를 통해 불러오게 됩니다. 그런데 사용자가 빠르게 스크롤하여 해당 셀이 화면에서 사라지면, 아직 로딩 중인 이미지 작업은 더 이상 필요하지 않게 되죠. 이런 상황에서 여전히 보이지 않는 셀을 위한 네트워크 요청을 계속 유지하는 것은 비효율적이며, 시스템 리소스를 낭비하게 됩니다.

Swift Concurrency가 도입되기 전까지는 이러한 비동기 작업을 안전하고 구조적으로 취소하기가 까다로웠습니다.

예를 들어 `DispatchQueue`를 사용할 경우, `DispatchWorkItem`을 생성해 `cancel()`을 호출함으로써 작업을 취소할 수는 있었지만, 
* 취소 상태의 전파가 어렵고,
* 중첩 작업이나 비동기 체인의 관리가 까다로웠습니다.

이런 한계를 보완하기 위해 `OperationQueue`를 사용하는 방법도 있었지만, 구현이 복잡하고 코드 양이 많아지는 단점이 있었습니다.

```swift
let globalQueue = DispatchQueue.global()

var outerItem = DispatchWorkItem {
    for i in 0...10 {
        if outerItem.isCancelled { break }
        sleep(1)
        print("➡️ 외부 작업 수행 완료: \(i)")
    }
    
    let innerItem = DispatchWorkItem { 
        for j in 0...10 {
            print("✨ 내부 작업 수행 완료: \(j)")
        }
    }
    globalQueue.async(execute: innerItem)
}
globalQueue.async(execute: outerItem)

globalQueue.asyncAfter(deadline: .now() + 3) {
    outerItem.cancel()
}
```

위 예제는 GCD 기반 비동기 처리에서 취소가 구조적으로 전파되지 않는 한계를 보여줍니다. 외부 작업이 취소되었지만, 그 내부에서 등록된 작업은 여전히 실행됩니다. 이는 Swift Concurrency의 `Task`와는 달리, **취소 전파(cancellation propagation)** 가 이루어지지 않기 때문입니다.

Swift Concurrency는 보다 구조화되고 이해하기 쉬운 방식으로 작업 취소를 지원하며, 이에 따라 작업의 취소 여부를 쉽게 확인하고 필요한 경우 예외 처리를 수행할 수 있는 API를 제공합니다. 구조화된 동시성(Structured Concurrency)에서는 작업이 상위-하위 관계의 트리(Task Tree) 형태로 구성됩니다. 이 구조에서는 상위 작업에서 취소 신호가 발생하면, 해당 신호가 모든 하위 작업에게 전파됩니다. 하위 작업들은 작업 컨텍스트를 스스로 정리(clean up)한 후, 상위 작업에게 종료를 알리고, 모든 하위 작업이 정리되면 상위 작업도 함께 종료됩니다. 구조화되지 않은 동시성(Unstructured)은 작업 트리를 구성하지 않기 때문에, 작업 취소가 전파되지 않습니다. 즉, 바깥 작업이 취소되더라도, 별도로 생성된 안쪽 작업은 해당 취소 전파를 받지 못하며, 독립적으로 계속 실행됩니다.

 Swift Concurrency **협력적 취소(Cooperative Cancellation)** 모델을 따릅니다. 각 작업은 실행 도중에 스스로 취소 여부를 확인하고, 그에 맞는 처리를 해주어야 합니다. 즉, 상위 작업이 하위 작업에게 취소 신호를 전파하더라도, 하위 작업이 곧바로 종료되지 않습니다. 단순히 `Task.isCancelled` 프로퍼티를 `true`로 바꿀 뿐입니다. 이는 각 작업마다 취소를 처리하는 방식이 다를 수 있기 때문입니다. 어떤 작업은 취소 시 중간 데이터를 반환할 수도 있고, 어떤 작업은 아예 예외를 던져버릴 수도 있습니다. 작업을 구성할 때는 늘 작업의 취소를 고려하여 설계하여야 합니다.

Swift Concurrency에서는 작업 내부에서 아래와 같은 방식으로 취소 상태를 확인할 수 있습니다:

* `Task.isCancelled`: 작업이 취소되었는지 여부를 확인 (true / false)

* `Task.checkCancellation()`: 취소되었을 경우 `CancellationError`를 던짐

일반적으로, 작업 취소 여부만 감지하고 따로 처리할 경우에는 `Task.isCancelled`를 사용합니다. 반변에 즉시 작업을 취소하고 흐름을 끊어야 할 상황이라면 `Task.checkCancellation()`을 사용해 `CancellationError`를 던지는 방식이 적합합니다.



### 구조화된 동시성(Structured Concurrency)

구조화된 동시성(Structured Concurrency)에서는 작업이 상위-하위 관계의 트리(Task Tree) 형태로 구성됩니다. 이 구조에서는 상위 작업에서 취소 신호가 발생하면, 해당 신호가 모든 하위 작업에게 전파됩니다. 하위 작업들은 작업 컨텍스트를 스스로 정리(clean up)한 후, 상위 작업에게 종료를 알리고, 모든 하위 작업이 정리되면 상위 작업도 함께 종료됩니다.

구조화된 동시성(Structured Concurrency)에서의 작업 취소 전파는 두 가지 방식으로 나눌 수 있습니다. 바로 **암시적(implicit) 취소 전파** 와 **명시적(explicit) 취소 전파**입니다. 이 두 방식은 취소 신호를 처음 전파하는 주체가 다르다는 점에서 구분되지만, 한 번 취소가 시작되면 해당 작업 트리의 모든 하위 작업에게 일괄적으로 취소 신호가 전파되며, 상위 작업은 모든 하위 작업이 종료된 후에야 함께 종료된다는 점은 동일합니다.


#### 암시적 취소 전파

**암시적 취소 전파** 는 하위 작업 중 하나가 상위 작업에 예외에 예외를 던지는 경우에 발생합니다. 하위 작업이 예외를 던지면, 이 예외를 받은 상위 작업은 나머지 실행 중인 하위 작업들에게 취소를 전파합니다. 여기서 중요한 점은, 상위 작업이 하위 작업의 예외를 실제로 받아야만 나머지 하위 작업에 취소가 전파된다는 것입니다. 즉, 예외가 상위 작업에서 무시되거나, 하위 작업에서 처리한다면, 다른 작업은 계속 실행될 수 있습니다.

> 📦 downloadImagesParallel()  ← 2️⃣ 하위 작업이 던진 예외 받음 <br>
>  ├── 🧵 downloadImage(from: url)  <br>
>  ├── 🧵 downloadImage(from: url)  ← 1️⃣ 예외 발생 및 상위 작업으로 throw <br>
>  └── 🧵 downloadImage(from: url)  ← 3️⃣ (실행 중인) 하위 작업에 취소 전파 <br>

아래 예제는 `TaskGroup`으로 여러 이미지를 병렬로 다운로드하는 작업 중, 일부 하위 작업에서 예외가 발생하면 나머지 작업에 암시적으로 취소가 전파되는 구조를 보여줍니다.

```swift
let url = "https://picsum.photos/200/300"

func downloadImage(from url: String) async throws -> UIImage {
    do {
        try Task.checkCancellation()  // 👈 네트워크 전에 취소 상태 확인
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    } catch {
        print("🟡 작업이 취소되었습니다.")
        throw error
    }
}

func faileDownloadImage() async throws -> UIImage {
    try await Task.sleep(for: .seconds(1))
    throw CancellationError()
}

func downloadImages() async throws -> [UIImage] {
    try await withThrowingTaskGroup(of: UIImage.self) { group in
        group.addTask { 
            try await downloadImage(from: url)
        }
        group.addTask { 
            try await faileDownloadImage() // 2️⃣ 예외 발생 및 상위 작업으로 throw
        }
        group.addTask { // 3️⃣ (실행 중인) 하위 작업에 취소 전파
            try await downloadImage(from: url)
        }
        
        var images: [UIImage] = []
        for try await image in group { // 1️⃣ 하위 작업이 던진 예외 받음
            images.append(image)
        }
        return images
    }
}
Task { try? await downloadImages() }
```

> 💡 Note: URLSession의 `data(from:)` 메서드는 작업 실행 중 취소 신호를 수신하면 `URLError.cancelled` 예외를 발생시키며, 해당 네트워크 요청을 중단합니다.



#### 명시적 취소 전파

**명시적 취소 전파**는 `Task`의 `cancel()`을 호출하거나, `TaskGroup`의 `cancelAll()`을 통해 하위 작업으로 **취소 신호를 전파**함으로써 이루어집니다.

> 🔨 Task  ← 1️⃣ `cancel()` 호출 및 작업 취소 전파 <br>
>  &nbsp; ⎹ &nbsp; 📦 downloadImagesParallel()  ← 2️⃣ 작업 취소 전파 수신 및 하위 작업에 다시 전파  <br>
> &nbsp; ⎹  &nbsp; ├── 🧵 async let image1 = downloadImage(from: url)  ← 3️⃣ 작업 취소 및 예외 throw  <br>
> &nbsp; ⎹ &nbsp; ├── 🧵 async let image2 = downloadImage(from: url)  ← 3️⃣ 작업 취소 및 예외 throw  <br>
> &nbsp; ⎹ &nbsp; └── 🧵 async let image3 = downloadImage(from: url)  ← 3️⃣ 작업 취소 및 예외 throw  <br>
> &nbsp;└───────────────────────────────────────

이 구조는 상위 `Task`가 명시적으로 `cancel()`을 호출하면, 하위 작업들에게 취소 신호가 전파되고, 이들이 **리소스를 정리하거나 예외 처리를 수행**하는 방식입니다.

아래 예제는 `async-let`으로 병렬 이미지 다운로드를 수행하다, 1초 후 `Task.cancel()`을 통해 **하위 작업 전체에 취소가 전파**되는 모습을 보여줍니다.

```swift
func downloadImages() async throws -> [UIImage] {  // 2️⃣ 작업 취소 전파 수신 및 하위 작업에 다시 전파
    async let image1: UIImage = downloadImage(from: url) 
    async let image2: UIImage = downloadImage(from: url)
    async let image3: UIImage = downloadImage(from: url)
    
    return try await [image1, image2, image3] // 3️⃣ 작업 취소 및 예외 throw
}

Task {
    let task = Task {
        do {
            _ = try await downloadImages()
        } catch {
            print("🟡 Task: 작업이 취소되었습니다.")
        }
    }

    try await Task.sleep(for: .seconds(1))
    task.cancel() // 1️⃣ `cancel()` 호출 및 작업 취소 전파
}
```

`Task` 뿐만 아니라 `TaskGroup`도 `cancelAll()`을 호출하여 비슷한 방식으로 **하위 작업에 취소를 전파**할 수 있습니다.

아래 예제는 `TaskGroup`을 사용해 여러 이미지를 병렬로 다운로드하다가, 약 10장의 이미지가 수신되면 `cancelAll()`을 호출하여 남은 작업을 취소하는 구조입니다. 이후, 그 시점까지 다운로드가 완료된 이미지들만 반환합니다.

```swift
func downloadImages() async throws -> [UIImage] {
    try await withThrowingTaskGroup(of: UIImage.self) { group in // // 2️⃣ 작업 취소 전파 수신 및 하위 작업에 다시 전파
        for _ in 0..<1_000 {
            group.addTask { 
                try await downloadImage(from: url) // // 3️⃣ 작업 취소 및 예외 throw
            }
        }
        
        var images: [UIImage] = []
        

        for try await image in group {
            if images.count == 10 {
                group.cancelAll()  // 1️⃣ `cancelAll()` 호출 및 작업 취소 전파
            }
            
            images.append(image)
        }
        return images
    }
}
Task { try? await downloadImages() }
```

<br>

### 구조화되지 않은 동시성(Unstructured Concurrency)

구조화되지 않은 동시성은 구조화된 동시성과 달리, 작업의 취소 신호가 바깥 작업에서 안쪽 작업으로 자동으로 전파되지 않습니다. 이런 구조에서는 각 `Task`에 대해 수동으로 취소 전파를 하고, 필요한 처리를 해야 합니다.

아래 예제는 `task1` 내부에 `task2`를 생성하고, `task1.cancel()` 호출 이후에도 `task2`는 그대로 실행되어 완료되는 구조를 보여줍니다.

```swift
let task1 = Task {
    sleep(1)
    
    if Task.isCancelled {
        print("🟡 Task1: 작업이 취소되었습니다.")
    }
    
    let task2 = Task {
        if Task.isCancelled {
            print("🟡 Task2: 작업이 취소되었습니다.")
            return
        }
        
        print("➡️ Task2 작업이 완료되었습니다.")
    }
}
task1.cancel()

Print "🟡 Task1: 작업이 취소되었습니다."
Print "➡️ Task2 작업이 완료되었습니다."
```




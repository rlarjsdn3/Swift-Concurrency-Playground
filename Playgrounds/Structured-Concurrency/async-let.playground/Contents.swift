import UIKit

//: ---
//: ## async-let
//: ### 구조적 동시성, 비동기 함수를 병렬로 실행하는 첫 번째 방법
//: ---
//: **구조적 동시성(Structured Concurrency)**은 동시에 실행되는 여러 작업(`Task`)을
//: **작업 트리(task tree)** 형태로 계층적으로 구성하여, 상위 작업이 하위 작업을 쉽게 **관리**할 수 있도록 도와줍니다.
//:
//: 구조적 동시성을 활용해 작업을 생성하면 **명시적인 상위-하위 관계**가 형성됩니다.
//: 상위 작업은 **모든 하위 작업이 완료된 후에야** 종료될 수 있습니다.
//:
//: 또한, 상위 작업에서 **작업 취소가 발생하면**, 그 취소 요청은 하위 작업에게도 **전파**됩니다.
//: 이와 함께 상위 작업의 **자체적인 자원**(예: 우선순위, Task-Local 변수 등)도 하위 작업에 **자동 상속**됩니다.
//:
//: 그리고 구조적 동시성의 중요한 특징 중 하나는,
//: 하위 작업들이 **병렬(parallel)** 로 실행될 수 있다는 점입니다.
//: (물론 작업 간 의존성이 없고, 스케줄러가 병렬 실행을 허용할 경우)

//: 구조적 동시성(Structured Concurrency)라는 개념이 처음엔 생소하게 느껴질 수 있지만,
//: 우리는 이미 `구조적`이라는 개념을 익숙하게 받아들이고 있습니다.

//:
//: ---
//: ### 예제 1
func doSomething() {
    let number = 20
    if number > 10 {
        print("➡️ 흐름 1")
    } else {
        print("➡️ 흐름 2")
    }
}
doSomething()
//: ---

//: 위의 `doSomething()` 함수에서 상수 `number`는
//: 해당 함수의 **정적 스코프(static scope)** 내에서만 유효합니다. 즉, 함수가 끝나면 `number`도 사라지죠.
//:
//: 구조적 동시성도 마찬가지입니다. 특정 스코프에서 생성된 하위 작업은 (비동기 작업이라 하더라도)
//: 그 스코프의 생명주기 안에서만 유효하며,
//: 스코프를 벗어나거나 상위 작업이 종료되면 **하위 작업도 함께 종료**됩니다.

//: ---

//: 구조적 동시성을 학습하기 전에, 먼저 **구조화되지 않은 동시성(Unstructured Concurrency)**을 사용해
//: 여러 이미지를 다운로드하는 상황을 가정해보겠습니다.

//: ---
//: ### 예제 2
func downloadImages() async -> [UIImage] {
    var images: [UIImage] = []
    
    let image1 = try! await downloadImage(from: url)
    let image2 = try! await downloadImage(from: url)
    let image3 = try! await downloadImage(from: url)
    
    images.append(contentsOf: [image1, image2, image3])
    return images
}
Task { _ = await downloadImages() }
//: ---

//: 이 코드는 크게 복잡하지 않고 이해하기도 쉽습니다.
//: 그러나 **성능 측면에서는 다소 비효율적**인 부분이 존재합니다.
//:
//: `for-in` 반복문 안에서 `downloadImage(from:)` 비동기 함수를 호출하고 있지만,
//: 실제로는 이미지가 **순차적으로** 다운로드되고 있습니다.
//:
//: 즉, 첫 번째 이미지 다운로드가 시작되면 일시 중단(suspend)되었다가,
//: 완료된 후 다시 재개(resume)되고, 그 다음 이미지가 다운로드되는 식입니다.
//: 세 이미지 모두 **하나씩 차례대로** 처리되고 있어, **병렬 실행이 아닌 순차 실행**이 이루어집니다.

//: 하지만 이미지 다운로드 작업은 서로 간에 **의존성이 없는 독립적인 작업**입니다.
//: 따라서 굳이 순차적으로 처리할 이유가 없습니다.
//:
//: 오히려 **세 장의 이미지를 동시에 병렬로 다운로드**한 다음,
//: 그 결과가 필요한 시점에 데이터를 `await`하여 처리하는 방식이 더 효율적입니다.

//: 예제 ②를 병렬로 이미지들을 다운로드받도록 하려면 어떻게 해야 할까요?
//: 방법은 매우 간단합니다. 이미지 다운로드 코드 앞에 `async let` 키워드를 붙여주면 됩니다.
//: 이를 **동시적 바인딩(concurrent binding)** 이라고 합니다.

//: ---
//: ### 예제 3
func downloadImagesParallel() async -> [UIImage] {
    var images: [UIImage] = []
    
    async let image1 = downloadImage(from: url)
    async let image2 = downloadImage(from: url)
    async let image3 = downloadImage(from: url)
    
    images.append(contentsOf: try! await [image1, image2, image3])
    return images
}
Task { await downloadImagesParallel() }
//: ---

//: 위 코드에서 `async let`을 사용하면 **세 개의 이미지 다운로드 작업이 동시에 시작**됩니다.
//: 이후 `try await`로 해당 작업들을 기다리면서 필요한 시점에 결과를 받아올 수 있게 됩니다.
//: 덕분에 전체 다운로드 시간은 이미지 3장을 순차적으로 받을 때보다 훨씬 짧아집니다.

//: `downloadImagesParallel()` 비동기 함수를 호출해 `async let`을 사용하면 내부적으로 어떤 일이 일어날까요?
//:
//: `Swift 컴파일러`는 `downloadImagesParallel()` 함수를 하나의 **상위 작업(Parent Task)**으로 처리하고,
//: 그 안에서 선언된 세 개의 `async let` 이미지 다운로드 작업을 **하위 작업(Child Tasks)**으로 구성하는 **작업 트리(Task Tree)**를 생성합니다.

//: ---
//: 📦 downloadImagesParallel()  ← 상위 작업 (Parent Task)
//:  ├── 🧵 async let image1 = downloadImage(from: url)  ← 하위 작업 1
//:  ├── 🧵 async let image2 = downloadImage(from: url)  ← 하위 작업 2
//:  └── 🧵 async let image3 = downloadImage(from: url)  ← 하위 작업 3
//: ---

//: 이때 상위 작업은 **모든 하위 작업이 완료되어야** 종료될 수 있으며,
//: `downloadImagesParallel()` 함수도 하위 작업들이 끝나야 **완전히 반환**됩니다.
//:
//: 즉, 이 비동기 작업들은 모두 `downloadImagesParallel()` 함수의 **정적 스코프(static scope)** 내에서만
//: 유효하게 실행되며, 함수 밖의 다른 컨텍스트에 영향을 주지 않습니다.
//:
//: 덕분에 우리는 코드의 실행 범위를 명확하게 파악할 수 있고,
//: 더 안전하고 예측 가능한 비동기 코드를 작성할 수 있게 됩니다.



//: 앞서 살펴본 것처럼, `async let`을 사용한 동시적 바인딩에서는
//: 하위 작업의 결과가 실제로 사용되는 지점에서 반드시 `await`을 해야 합니다.
//:
//: 그렇다면, 만약 `await`을 하지 않는다면 어떤 일이 벌어질까요?
//:
//: 예상하셨듯이, 하위 작업들은 생성되자마자 실행되긴 하지만,
//: 해당 함수가 `await` 없이 즉시 반환(return)되면
//: 아직 완료되지 않은 하위 작업들은 모두 **자동으로 취소(cancel)** 됩니다.

//: ---
//: ### 예제 4
func downloadImagesAndReturnImmediately() async {
    async let image1 = downloadImage(from: url)
    async let image2 = downloadImage(from: url)
    async let image3 = downloadImage(from: url)
    
    // images.append(contentsOf: try! await [image1, image2, image3])
    print("➡️ await을 하지 않으면 곧바로 함수 스코프를 벗어나게 되면서 하위 작업이 모두 취소됩니다.")
    return
}
Task { await downloadImagesAndReturnImmediately() }
//: ---

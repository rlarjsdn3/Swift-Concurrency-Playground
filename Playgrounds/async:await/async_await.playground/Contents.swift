import UIKit

//: ---
//: # async・await
//: ## 비동기 함수・잠재적인 일시 중단 지점을 나타내는 키워드
//: ---
//: 비동기(asynchronous) 함수란, 실행된 후 결과를 반환하기까지 걸리는 시간을 예측할 수 없는 함수입니다.
//: 네트워크 통신처럼 외부 환경에 따라 속도가 달라지거나, 파일 I/O와 무거운 작업이 대표적인 비동기 작업입니다.

//: 비동기 작업은 메인 스레드의 부담을 덜어줌으로써,
//: UI 렌더링과 사용자 이벤트 처리 등 원활한 상호작용을 가능하게 해줍니다.
//:
//: 이러한 비동기 작업들은 주로 **백그라운드 스레드**에서 실행됩니다.
//: 예를 들어, 백그라운드에서 썸네일 이미지를 받아왔다고 가정해봅시다.
//: 이제 해당 이미지를 `UIImage`로 만들어 셀에 표시하려는 순간, **오류가 발생할 수 있습니다.**
//:
//: 그 이유는 **UI와 관련된 작업은 반드시 메인 스레드에서만 처리**해야 하기 때문입니다.
//: 백그라운드 스레드에서 `UIImageView`에 이미지를 설정하거나,
//: 뷰에 접근하는 작업을 수행하면 런타임 충돌(경고)이 발생할 수 있습니다.
//:
//: 비동기 작업에서 가장 중요한 것 중 하나는, **작업이 언제 완료되는지를 아는 것**입니다.
//: 작업이 완료되면 그 결과를 바탕으로 **UI를 갱신하거나 후속 작업을 처리**해야 하는데,
//: 이때 UI 갱신은 반드시 **메인 스레드**에서 이루어져야 하므로 별도의 처리가 필요합니다.
//:
//: 본격적으로 `Swift Concurrency`가 등장하기 전, 기존 방식에서는 이러한 흐름을 어떻게 처리했는지 먼저 살펴보겠습니다.

//: ---
//: ### 예제 1
func downloadImage(from url: String,
                    completion: @Sendable @escaping (Result<UIImage, any Error>) -> Void) {
    
    let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
        if let _ = error {
            completion(.failure(URLError(.unknown))) // 🔴 만약 콜백을 적는 걸 깜박한다면?
            return
        } else {
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(URLError(.unknown)))  // 🔴 만약 콜백을 적는 걸 깜박한다면?
                return
            }
            
            if let data = data,
               let image = UIImage(data: data) {
                
                prepareThumbnail(from: image) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            completion(.success(image)) // 🔴 만약 콜백을 적는 걸 깜박한다면?
                            return
                        }
                    }
                }
            } else {
                completion(.failure(URLError(.unknown)))  // 🔴 만약 콜백을 적는 걸 깜박한다면?
                return
            }
        }
    }
    
    task.resume()
}

downloadImage(from: url) { result in
    if let image = try? result.get() {
        DispatchQueue.main.async { //  🔴 만약 메인 디스패치 큐를 적는 걸 깜박한다면?
            // imageView.image = image
            print("➡️ 이미지 다운로드 완료: \(image)")
        }
    }
}
//: ---

//: 지금까지 우리가 흔히 사용해온 **비동기 콜백 기반 코드**입니다.
//: 썩 나쁘진 않지만, 이 방식에는 여러 가지 **잠재적인 버그**가 숨어 있습니다.
//:
//: 예를 들어, **콜백 호출을 깜빡하게 되면** 흐름이 끊기고 앱이 멈춘 것처럼 보일 수 있습니다. 그리고, **UI 작업을 백그라운드에서 처리하면** 런타임 충돌이 발생할 수 있습니다.
//: 뿐만 아니라, 콜백 기반 방식은 중첩된 클로저로 인해 코드의 **가독성도 떨어지고**, **흐름을 추적하기 어려운** 문제가 있습니다.

//: 이러한 문제를 해결하기 위해 등장한 것이 바로 `async/await`입니다.
//:
//: - `async` 키워드는 해당 함수가 **비동기 함수**임을 나타내며,
//:   매개변수 목록 뒤, 반환 타입 화살표(->) 앞에 위치합니다.
//:
//: - `await` 키워드는 비동기 함수 호출 지점에서 사용되며,
//:   해당 작업이 **일시 중단(suspend)** 될 수 있음을 나타냅니다.
//:   (`try` 키워드가 에러를 던질 수 있는 함수에서 필요한 것처럼 말이죠)
//:
//: `async/await`를 사용하면, 비동기 작업을 마치 동기 함수처럼 읽기 쉬운 형태로 표현할 수 있어 코드의 안정성과 가독성 모두를 크게 향상시킬 수 있습니다.
//: 아래 예제는 위 예제를 `async/await`을 활용해 다시 작성한 코드입니다.

//: ---
//: ### 예제 2
func downloadImageAsync(from url: String) async throws -> UIImage? {
    let (data, response) = try await URLSession.shared.data(from: URL(string: url)!) // 1
    if let response = (response as? HTTPURLResponse), response.statusCode != 200 {
        throw URLError(.unknown)
    }
    let image = UIImage(data: data) // 2
    let thumbnail = await image?.byPreparingThumbnail(ofSize: CGSize(width: 100, height: 100)) // 3
    return thumbnail
}

Task {
    let image = try? await downloadImageAsync(from: url)
    print("➡️ 이미지 다운로드 완료: \(image)")
}
//: ---

//: 코드가 훨씬 깔끔해졌죠? `async/await`를 사용하면 단순히 보기만 좋은 게 아닙니다.
//:
//: 깜빡하고 **예외 처리를 누락하거나**, **값 반환을 빼먹는 실수**도 **컴파일 타임에 방지**할 수 있습니다.
//: 덕분에 **가독성은 물론 안정성까지** 대폭 향상되죠.
//:
//: 그럼 이제 `downloadImageAsync(from:)` 메서드가
//: 내부적으로 어떻게 실행되는지, 코드를 **한 줄씩 차근차근** 살펴보겠습니다.

//: 1️⃣ `URLSession.shared.data(from:)`를 통해 지정된 URL로 네트워크 요청을 보냅니다.
//: 이 작업은 시간이 걸릴 수 있으므로, 비동기적으로 **일시 중단(suspend)** 됩니다.
//: 이 시점에 시스템은 스레드의 제어권을 회수해, 다른 작업을 처리할 수 있습니다.

//: 2️⃣ 이미지 다운로드가 완료되면, 시스템은 중단된 코드를 다시 **재개(resume)** 합니다.
//: 이후 받아온 데이터를 `UIImage`로 변환합니다.
//: 이 작업은 **동기적**이기 때문에 추가 중단 없이 바로 실행됩니다.

//: 3️⃣ 생성된 이미지를 썸네일로 변환합니다.
//: 이 과정도 시간이 걸릴 수 있어, 내부적으로 **비동기 처리**됩니다.
//: 썸네일 생성이 완료되면 최종 결과가 반환되고, 호출자는 이를 사용할 수 있게 됩니다.

//: ---

//: 핵심은 바로 **"시스템이 스레드의 제어권을 회수한다"**는 점입니다.
//:
//: 기존의 `GCD` 방식에서는 시간이 오래 걸리는 작업을 만나면,
//: 그 작업이 끝날 때까지 **해당 스레드를 계속 붙잡고(blocking)** 있어야 했습니다.
//: 다시 말해, 그 스레드는 아무 일도 하지 않은 채 **놀고 있는 셈**이죠.

//: 반면, `Swift Concurrency`에서는 `await` 키워드를 만나면
//: 작업이 **일시 중단(suspend)** 되고, 그 순간 **스레드의 제어권이 시스템에 반환**됩니다.
//:
//: 시스템은 해당 스레드를 다른 작업에 효율적으로 **재할당**할 수 있고,
//: 원래의 중단된 작업은 나중에 적절한 시점에 자동으로 다시 **재개(resume)** 됩니다.

//: ---
//: ### 📊 그림 1 — Swift Concurrency의 동작 흐름 예시
//:
//:           --------------------------------------------------------------
//: Thread 2: | 작업 A | 💥 suspend       | 작업 B |       💨 resume | 작업 A |
//:           --------------------------------------------------------------
//:
//: 위 그림처럼, 작업 A가 `await`에서 일시 중단되면
//: 시스템은 그 사이에 작업 B를 처리하고,
//: 다시 작업 A를 이어서 처리합니다 — 이것이 **논블로킹 비동기 처리의 핵심**입니다.
//: ---

//: 참고로, 작업 A가 ②번 스레드에서 일시 중단된다 하더라도, 재개할 때는 ②번 스레드가 아닌 다른 스레드에서 재개될 수 있습니다.


//: 비동기 함수는 반드시 **비동기 컨텍스트** 내부에서만 호출할 수 있습니다.
//: 즉, `Task` 블록 내부나 **다른 비동기 함수**에서 호출해야 합니다. 일반적인 동기 함수 내에서는 `await`를 사용할 수 없습니다.

//: ---
//: ### 예제 3
func doSomething() async -> String {
    "Hello, Swift Concurrency!"
}

// ✅ Task 블록 안에서 호출하는 경우
Task {
    let message = await doSomething()
    print("➡️ Task 블록 내부에서 `비동기 함수`를 호출할 수 있습니다.")
}

// ✅ 다른 비동기 함수 안에서 호출하는 경우
func doAnotherSomething() async {
    let message = await doSomething()
    print("➡️ 다른 비동기 함수에서 `비동기 함수`를 호출할 수 있습니다.")
}
//: ---



//: 아래 예제는 `async/await`를 활용해 비동기 작업을 처리하는 다양한 방법들을 보여줍니다.

//: ---
//: ### 예제 4
func printMagicNumber(_ number: Int) async throws {
    print("🧙‍♂️ 마법의 수는 \(number)입니다!")
}

Task {
    try? await printMagicNumber(1)
    try?await printMagicNumber(2)
    
    Task {
        try? await Task.sleep(for: .seconds(1))
        try?await printMagicNumber(3)
        try?await printMagicNumber(4)
    }
    
    try?await printMagicNumber(5)
}

// Print  "🧙‍♂️ 마법의 수는 1입니다!"
// Print  "🧙‍♂️ 마법의 수는 2입니다!"
// Print  "🧙‍♂️ 마법의 수는 5입니다!"
// Print  "🧙‍♂️ 마법의 수는 3입니다!"
// Print  "🧙‍♂️ 마법의 수는 4입니다!"
//: ---


//: ---
//: ### 예제 5
func printMagicNumbers() async throws {
    try await Task.sleep(for: .seconds(3))
    _ = try? await printMagicNumber(10)
    try await Task.sleep(for: .seconds(3))
    _ = try? await printMagicNumber(20)
    try await Task.sleep(for: .seconds(3))
    _ = try? await printMagicNumber(30)
}

Task {
    do {
        try await printMagicNumbers()
    } catch {
        print(error)
    }
}

// Print  "🧙‍♂️ 마법의 수는 10입니다!"
// Print  "🧙‍♂️ 마법의 수는 20입니다!"
// Print  "🧙‍♂️ 마법의 수는 30입니다!"
//: ---

## [부록] 새로운 Swift Concurrency 문법

#### 비동기 계산 프로퍼티

```swift
var image: UIImage {
    get async {
        await downloadImage()
    }  
}
```

```swift
var image: UIImage {
    get async throws {
        try await Task.sleep(for: .seconds(1))
        return await downloadImage()
    }
}
```

```swift
Task { try await image }
```

* 비동기 계산 프로퍼티는 `getter`만 선언 가능

<br>

#### 프로토콜 - 비동기 함수 선언

```swift
protocol ImageDownloader {
    var image: UIImage { get async }
}
```

```swift
protocol ImageDownloader {
    var image: UIImage { get async throws }
}
```

#### 프로토콜 - 비동기 프로퍼티 선언

```swift
protocol Cachable {
    func loadData() async -> Data
}
```

```swift
protocol Cachable {
    func loadData() async throws -> Data
}
```

#### 비동기 함수 타입

```swift
var onCompletion: () async -> Void
```

```swift
var onCompletion: () async throws -> Void
```

```swift
var onCompletion: @Sendable () async throws -> Void
```

#### 비동기 함수(매개변수) 타입

```swift
func doSomething(_ work: (Int) async throws -> Int) {
    // ...
}
```

```swift
doSomething { return try await doubleNumbers($0) }
```


#### 비동기 이니셜라이저

```swift
class DataFetcher {
    var data: Data?
    
    init(url: URL) async throws {
        self.data = try await downloadData(from: url)
    }
    func downloadData(from: url: URL) async throws -> Data {
        // ...
    }
}
```

```swift
Task {
    let ... = try await DataFetcher(url: url)
}
```

#### 비동기 반복문

```swift
for try await image in group {
    // ...
}
```







import UIKit

//: ---
//: ## TaskGroup
//: ### 구조적 동시성, 비동기 함수를 병렬로 실행하는 두 번째 방법
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


//: ---
//: 📦 downloadImagesParallel()  ← 상위 작업 (Parent Task)
//:  ├── 🧵 async let image1 = downloadImage(from: url)  ← 하위 작업 1
//:  ├── 🧵 async let image2 = downloadImage(from: url)  ← 하위 작업 2
//:  └── 🧵 async let image3 = downloadImage(from: url)  ← 하위 작업 3
//: ---


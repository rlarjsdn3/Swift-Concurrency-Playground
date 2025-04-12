# Swift Concurrency Playground

> **💡 Note:** 이 리포지토리를 기반으로 작성된 문서를 보시려면 [여기](https://rlarjsdn3.gitbook.io/swift-concurrency-kr)를 클릭하세요.

🛝Swift Concurrency의 다양한 기능과 기술을 실험하고 학습하기 위한 플레이그라운드입니다.


### 🕊️ Programming Guide

* [Task](programming-guide/Task.md) <br> 비동기 작업을 실행하고 제어할 수 있는 기본 단위입니다.
* [Detached Task](programming-guide/Detached_Task.md) <br> 비동기 작업을 실행하고 제어할 수 있는 기본 단위입니다. 단, 기존 컨텍스트와는 독립적으로 동작합니다.
* [async/await](programming-guide/async_await.md) <br> 비동기 코드 작성을 동기 코드처럼 간결하게 할 수 있게 해주는 Swift의 문법입니다.
* [async-let](programming-guide/async-let.md) <br> 여러 비동기 작업을 동시에 시작하고 나중에 결과를 병렬로 기다릴 수 있도록 해주는 간편한 구문입니다.
* [TaskGroup](programming-guide/TaskGroup.md) <br> 여러 비동기 작업을 그룹으로 묶어 병렬 처리하고 결과를 쉽게 모을 수 있게 해주는 구조입니다.
* [Continuation](programming-guide/Continuation.md) <br> 기존의 콜백 기반 비동기 코드를 async/await 스타일로 변환할 수 있게 해주는 브릿지 도구입니다.
* [Cancellation](programming-guide/Cancellation.md) <br> 실행 중인 비동기 작업을 취소하는 협력적 취소(Cooperative Cancellation)를 알아봅시다.
* [Task-Local](programming-guide/Task-Local.md) <br> 특정 Task 내부에서만 접근 가능한 지역 데이터 저장소입니다.
* [Sendable](programming-guide/Sendable.md) <br> 동시성 환경에서 안전하게 전달될 수 있는 타입임을 나타내는 프로토콜입니다.
* [AsyncSequence](programming-guide/AsyncSequence.md) <br> (내용)
* [AsyncStream](programming-guide/AsyncStream.md) <br> (내용)
* [Actor](programming-guide/Actor.md) ([Syntax Rules](programming-guide/Actor-Syntax-Rules.md)) <br> 동시성 문제를 원천적으로 차단하는 새로운 타입을 알아봅시다.

### 📚 Appendix

* [New Concurrency Syntax](Appendix/new-concurrency-syntax.md) <br> 새롭게 추가된 동시성 문법을 알아봅시다. 
* [Structured vs.Unstructured Concurrency](Appendix/structured-vs-unstructured-concurrency.md) <br> 구조적 동시성과 구조화되지 않은 동시성의 차이를 알아봅시다.

### 💾 Sample Projects

* [Image](projects/image/image) <br> 컬렉션 뷰에서 이미지를 불러오고, 취소하는 방법을 알아봅시다. 액터를 활용해 캐시에 안전하게 접근하고, 액터의 재진입성으로 인해 발생하는 문제를 해결해 봅시다.
* [Map](projects/Map/Map) <br> 기존 델리게이트 방식의 API를 async/await으로 변환해 봅시다.
* [FileCompressor](projects/FileCompressor) <br> 액터 경합(Actor Contention)으로 인해 발생하는 성능 문제를 최적화해봅시다. 
* [LocationApp](projects/LocationApp) <br> AsyncStream을 활용해 위치 정보를 비동기적으로 지속적으로 받아오는 구조를 구현해봅시다.


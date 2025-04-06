# Swift Concurrency Playground

🛝Swift Concurrency의 다양한 기능과 기술을 실험하고 학습하기 위한 플레이그라운드입니다.

### Overview

* [개요](overview/Overview.md) <br>

### Programming Guide

* [Task](programming-guide/Task.md) <br> Swift에서 비동기 작업을 실행하고 제어할 수 있는 기본 단위입니다.
* [async/await](programming-guide/async_await.md) <br> 비동기 코드 작성을 동기 코드처럼 간결하게 할 수 있게 해주는 Swift의 문법입니다.
* [async-let](programming-guide/async-let.md) <br> 여러 비동기 작업을 동시에 시작하고 나중에 결과를 병렬로 기다릴 수 있도록 해주는 간편한 구문입니다.
* [TaskGroup](programming-guide/TaskGroup.md) <br> 여러 비동기 작업을 그룹으로 묶어 병렬 처리하고 결과를 쉽게 모을 수 있게 해주는 구조입니다.
* [Continuation](programming-guide/Continuation.md) <br> 기존의 콜백 기반 비동기 코드를 async/await 스타일로 변환할 수 있게 해주는 브릿지 도구입니다.
* [Cancellation](programming-guide/Cancellation.md) <br> 실행 중인 비동기 작업을 취소하는 협력적 취소(Cooperative Cancellation)를 알아봅시다.
* [Sendable](programming-guide/Sendable.md) <br> 동시성 환경에서 안전하게 전달될 수 있는 타입임을 나타내는 프로토콜입니다.
* [Task-Local](programming-guide/Task-Local.md) <br> 특정 Task 내부에서만 접근 가능한 지역 데이터 저장소로, 트리 구조로 값이 전달됩니다.
* [Actor](programming-guide/actor.md) <br> 데이터 경합을 방지하기 위해 상태를 보호하고 한 번에 하나의 작업만 수행할 수 있도록 보장하는 타입입니다.
* [AsyncSequence](programming-guide/AsyncSequence.md) [AsyncStream](programming-guide/AsyncStream.md) <br> 비동기적으로 순차적으로 값을 생성하고 소비할 수 있는 시퀀스 프로토콜과 그 구현체입니다.


### Appendix

* [새로운 동시성 문법](Appendix/new-concurrency-syntax) <br> 새롭게 추가된 동시성 문법을 알아봅시다. 
* [동기 vs. 비동기, 직렬 vs. 병렬](Appendix/sync-vs-async-serial-vs-parellel.md) <br> 동기와 비동기, 직렬와 병렬 개념을 알아봅시다.
* [구조적 동시성 vs. 구조화되지 않은 동시성](Appendix/structured-vs-unstructured-concurrency.md) <br> 구조적 동시성과 구조화되지 않은 동시성의 차이를 알아봅시다.
* [CS 관점에서 바라본 async/await](Appendix/sync-await-in-cs.md) <br> 어떻게 코드가 일시 중단(suspend)되고, 다시 재개(resume)될 수 있을까요? 그 마법을 파헤쳐 봅시다.
* [Actor가 내부 상태를 보호하는 방법](Appendix/actor-state-isolation.md) <br> 액터는 어떻게 내부 상태를 효율적으로 보호할 수 있을까요? 그 내부를 톺아봅시다,
* [Swift Concurrency 사용 시 주의사항](Appendix/swift-concurrency-caveats.md) <br> `Swift Concurrency` 사용 시 주의사항을 한 눈에 정리해봅시다.

### Sample Projects

* [Image](projects/image/image) <br> 컬렉션 뷰에서 이미지를 불러오고, 취소하는 방법을 알아봅시다. Actor를 활용해 공유 가변 상태에 안전하게 접근하고, 액터의 재진입성 문제를 해결해 봅시다.
* [Map](projects/Map/Map) <br> 기존 델리게이트 방식의 API를 async/await으로 변환해 봅시다.

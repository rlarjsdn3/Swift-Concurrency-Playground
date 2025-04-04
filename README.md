# Swift Concurrency Playground

🛝Swift Concurrency의 다양한 기능과 기술을 실험하고 학습하기 위한 플레이그라운드입니다.

### Programming Guide

* [Task]() <br> Swift에서 비동기 작업을 실행하고 제어할 수 있는 기본 단위입니다.
* [async/await]() <br> 비동기 코드 작성을 동기 코드처럼 간결하게 할 수 있게 해주는 Swift의 문법입니다.
* [async-let]() <br> 여러 비동기 작업을 동시에 시작하고 나중에 결과를 병렬로 기다릴 수 있도록 해주는 간편한 구문입니다.
* [TaskGroup]() <br> 여러 비동기 작업을 그룹으로 묶어 병렬 처리하고 결과를 쉽게 모을 수 있게 해주는 구조입니다.
* [Continuation]() <br> 기존의 콜백 기반 비동기 코드를 async/await 스타일로 변환할 수 있게 해주는 브릿지 도구입니다.
* [Cancellation]() <br> 실행 중인 비동기 작업을 취소하는 협력적 취소(Cooperative Cancellation)를 알아봅시다.
* [Sendable]() <br> 동시성 환경에서 안전하게 전달될 수 있는 타입임을 나타내는 프로토콜입니다.
* [Task-Local]() <br> 특정 Task 내부에서만 접근 가능한 지역 데이터 저장소로, 트리 구조로 값이 전달됩니다.
* [Actor]() <br> 데이터 경합을 방지하기 위해 상태를 보호하고 한 번에 하나의 작업만 수행할 수 있도록 보장하는 타입입니다.
* [AsyncSequence/AsyncStream]() <br> 비동기적으로 순차적으로 값을 생성하고 소비할 수 있는 시퀀스 프로토콜과 그 구현체입니다.

### Appendix

* [동기 vs. 비동기, 비동기 vs. 병렬]() <br>
* [구조적 동시성 vs. 구조화되지 않은 동시성]() <br>
* [CS 관점에서 바라본 async/await]() <br>
* [Swift Concurrency 사용 시 주의사항]() <br>

### Sample Projects

* [ImageProject]() <br> (내용)
* [MapProject]() <br> (내용)

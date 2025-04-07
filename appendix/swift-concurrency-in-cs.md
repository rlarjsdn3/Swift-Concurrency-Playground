## [부록] CS로 이해하는 Swift Concurrency



# GCD - 한계점

사용자가 최신 뉴스를 보고 싶다고 요청했다고 가정해 보겠습니다. 이때, 메인 스레드에서 사용자 이벤트 제스처를 처리하게 됩니다. 이후, 데이터베이스 작업을 담당하는 직렬 큐로 비동기 디스패치하여 데이터베이스에서 필요한 정보를 가져오도록 합니다.

```swift
let urlSession = URLSession(configuraiton: .default: delegate: self,
                            delegateQueue: concurrentQueue)
                            
for feed in feedsToUpdate {
    let dataTask = urlSession.dataTask(with feed.url) { data, response, error in 
        /* ... */
        guard let data = data else { return }
        do {
            let articles = try deserializeArticles(from: data)
            databaseQueue.sync {
                updateDatabase(with: articles)
            }
        } catch { /* ... */ }
    }
    dataTask.resume()
}
```

데이터 작업의 완료 핸들러는 동시 큐에서 실행되며, 여기에서 다운로드한 결과를 역직렬화하고 기사 형식으로 변환합니다. 이후, 데이터베이스의 결과를 업데이트하기 전에 데이터베이스 큐에서 sync 호출을 수행하여 동기적으로 데이터를 저장합니다

만약 특정 스레드가 블로킹되는 경우, 동시에 실행할 수 있는 추가 작업이 있을 때 GCD는 더 많은 스레드를 생성하여 남은 작업을 처리하려 합니다. 이는 CPU 활용도를 최대로 끌어올리는 방식이지만, 잘못 관리될 경우 과도한 스레드 생성으로 인해 불필요한 컨텍스트 스위칭과 리소스 낭비가 발생할 수 있습니다.

프로세스에 추가적인 스레드를 할당함으로써, 각 CPU 코어가 언제나 작업을 실행할 수 있도록 보장할 수 있습니다.

이제 이런 질문이 나올 수 있습니다. “애플리케이션에서 많은 스레드를 가지는 게 왜 문제가 될까?” 애플리케이션에서 너무 많은 스레드를 생성하면, 시스템은 CPU 코어 수보다 훨씬 많은 스레드를 실행하려고 시도하게 됩니다. 즉, 스레드가 과도하게 할당(overcommit)되는 상황이 발생합니다. 예를 들어, iPhone에 6개의 CPU 코어가 있다고 가정해 보겠습니다. 만약 우리 뉴스 앱이 100개의 피드 업데이트를 처리해야 한다면, iPhone은 CPU 코어보다 16배 더 많은 스레드를 처리해야 합니다. 이것이 바로 우리가 스레드 폭발(thread explosion)이라고 부르는 현상입니다.

 스레드 폭발은 단순히 실행 속도 저하만 초래하는 것이 아니라, 메모리 소비 증가와 스케줄링 오버헤드를 동반합니다.
 
 각 블로킹된 스레드는 스택과 커널에서 해당 스레드를 추적하는 데이터 구조를 유지하고 있어, 실행되지 않는 동안에도 중요한 시스템 자원을 소비합니다. 또한, 일부 스레드는 특정 락(lock)을 점유하고 있을 수 있으며, 이 락을 필요로 하는 다른 스레드들은 실행되지 못하고 대기하게 됩니다. 결과적으로, 진행되지 않는 스레드들이 불필요한 메모리와 리소스를 차지하게 됩니다.
 
  하지만 스레드 폭발이 발생하면, 한정된 코어를 가진 기기에서 수백 개의 스레드를 시분할해야 하므로 과도한 컨텍스트 스위칭이 일어날 수 있습니다. 그 결과, 이러한 스레드들의 스케줄링 지연 시간이 실제 유용한 작업 수행 시간을 초과하게 되고, 이는 CPU의 비효율적인 실행을 초래하게 됩니다.

Escessive concurrency

Overcommting the system with more threads than CPU Cores

Thread Explosion

Performance costs

* Memory overhead

* Scheduling overhead






# Swift Concurrency - 협력적 스레드 풀

 Swift 동시성을 적용하면, 두 개의 코어를 가진 시스템에서 단 두 개의 스레드만 실행되며, 컨텍스트 스위칭이 전혀 발생하지 않습니다. 또한, 블로킹된 스레드가 완전히 사라지고, 대신 경량 객체인 컨티뉴에이션(Continuation)이 사용됩니다. Swift 동시성에서는 스레드가 작업을 실행할 때, 전체적인 스레드 컨텍스트 스위칭을 수행하는 것이 아니라, 컨티뉴에이션 간 전환을 수행합니다. 이를 통해 스케줄링 오버헤드를 줄이고 CPU를 훨씬 더 효율적으로 활용할 수 있게 되었습니다.

Swift 동시성이 목표로 하는 런타임 동작은 CPU 코어 수만큼의 스레드만 생성하고, 스레드가 블로킹될 때 비용이 거의 들지 않는 방식으로 작업 간 전환을 수행하는 것입니다. 이를 통해 직관적으로 이해할 수 있는 직선형 코드를 작성하면서도 안전하고 구조화된 동시성을 제공하는 것을 목표로 합니다.

협력적 스레드 풀은 CPU 코어 수만큼의 스레드만 생성하여 시스템에 과부하가 걸리지 않도록 합니다. GCD의 동시 큐는 작업이 블로킹될 때 더 많은 스레드를 생성하는 것과 달리, Swift에서는 스레드가 항상 진행할 수 있습니다. 따라서 기본 런타임은 생성되는 스레드의 수를 신중하게 제어할 수 있습니다. 이를 통해 애플리케이션에 필요한 동시성을 제공하면서도 과도한 동시성으로 인한 잘 알려진 문제를 방지할 수 있습니다.

Coorperative thread pool

default executor for swift

width limited to the number of cpu cores

controlled granularity of concurrency - worker threads don't block, avoid thread explosion and excessive context switches

이런 이유로 Swift Concurrency는 비동기와 병렬의 단어 구분이 그다지 의미가 없다. 왜냐하면 각 CPU 코어(스레드)는 모두 단 하나의 스레드만을 가지고, 스레드 양보를 해가며 비선점형으로 작동하기 때문에 이미 그 자체로 병렬적이기 때문



# 비동기 함수가 일시중단되고 다시 재개되는 방법

비동기 함수는 어떻게 실행되는 중간에 일시 중단(suspend)되고, 다시 재개(resume)될 수 있을까요? 

```swift
// on Feed
func add(_ newArticles: [Article]) async throws {
    let ids = try await database.save(newArticles, for: self)
    for (id, article) in zip(ids, newArticles) {
        articles[id] = article
    }
}

func updateDatabasse(...) async {
    // skip old articles...
    await feed.add(articles)
}
```

 스레드가 updateDatabase 함수 내에서 Feed의 add(_:) 메서드를 호출했다고 가정해 보겠습니다. 이 시점에서 최상단의 스택 프레임은 add(:) 함수가 됩니다. 스택 프레임은 일시 중단과 관련이 없는 지역 변수들을 저장합니다. _add(_:)의 본문을 보면, await 키워드로 표시된 하나의 일시 중단 지점이 있습니다. 이제 id와 article이라는 지역 변수를 살펴보겠습니다. 로컬 변수인 id와 article은 정의된 직후, 중간에 일시 중단 지점 없이 즉시 for 루프 본문에서 사용됩니다. 따라서 이 변수들은 기존의 스택 프레임에 저장됩니다.

```
+-------------------------+
|       Thread Stack      |
+-------------------------+
|  add()                  |  <-- 현재 실행 중
+-------------------------+


+-------------------------+
|         Heap            |
+-------------------------+
|  add()                  |  ←── Continuation
+-------------------------+
|  updateDatabase()       |
+-------------------------+
```

힙에는 updateDatabase와 add를 위한 두 개의 비동기 프레임이 존재하게 됩니다. 비동기 프레임은 일시 중단 지점들을 넘어 계속 필요할 정보를 저장합니다. newArticles 인자가 await 이전에 정의되었지만 await 이후에도 필요하다는 점에 주목하세요. 이는 add의 비동기 프레임이 newArticles를 추적해야 함을 의미합니다.

```
```

 save 함수가 실행되기 시작하면, add의 스택 프레임은 save의 스택 프레임으로 대체됩니다. 새로운 스택 프레임이 추가되는 대신, 최상위 스택 프레임이 교체됩니다. 이는 앞으로 필요할 변수들이 이미 비동기 프레임 목록에 저장되어 있기 때문입니다.
 
 ```
 ```
 
 이 스레드는 이전과 동일한 스레드일 수도 있고, 다른 스레드일 수도 있습니다. 이제 save 함수가 해당 스레드에서 다시 실행을 재개한다고 가정해 보겠습니다. save 함수가 실행을 마치고 일부 ID를 반환하면, 기존의 save 함수 스택 프레임은 제거되고, 다시 add(_:) 함수의 스택 프레임이 복원됩니다. 그 이후, 스레드는 zip 함수를 실행할 수 있습니다. 배열 두 개를 합치는 zip 연산은 비동기 함수가 아니므로, 새로운 스택 프레임이 생성됩니다.

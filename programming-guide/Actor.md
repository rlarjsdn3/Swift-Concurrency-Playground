## Actor
**특정 작업 컨텍스트 내에 바인딩하고 읽을 수 있는 값**

---

### 액터(Actor)

`Actor`는 

액터는 공유된 가변 상태를 위한 동기화 메커니즘을 제공합니다. 액터는 고유한 상태를 가지며, 그 상태는 프로그램의 다른 부분으로부터 격리되어 있습니다. 해당 상태에 접근하는 유일한 방법은 액터를 통해서만 가능하며, 액터를 통해 접근할 때마다 액터의 동기화 메커니즘이 동작하여 다른 코드가 동시에 액터의 상태에 접근하지 못하도록 보장합니다.

이것은 우리가 직접 락이나 직렬 디스패치 큐를 사용할 때 얻을 수 있는 상호 배제(mutual exclusion)와 동일한 효과를 줍니다. 하지만, 액터를 사용하면 Swift가 이를 기본적으로 보장합니다. 동기화를 깜빡하는 일이 발생할 수 없으며, 만약 그렇게 시도하면 Swift는 컴파일 오류를 발생시켜 이를 막습니다.

- 참조 타입 / 속성, 메서드, 이니셜라이저, 서브스크립트를 가질 수  있음 / 프로토콜 채태 가능 / 확장 가능 / Sendable 프로토콜과 Actor 프로토콜 암시적 채택
- 단, 상속은 안됨


- 참조 타입으로 힙 메모리 영역에 저장되어 여러 스레드에서 접근할 수 있지만, 한번에 하나의 스레드에서만 접근할 수 있도록 처리해 스레드에 안전하게 처리해줌



- 액터는 프로그램의 나머지 부분으로부터 내부 프로퍼티나 메서드를 격리(isolated)시켜서 내부 상태를 보호함, 액터 외부에서 액터 내부에 접근하려면 항상 비동기(async)적으로 접근해야 함

- 해당 액터에 접근할 때는 `await` 키워드를 붙여야 함. 이는 여러 스레드에게 해당 액터에 동시에 접근할 때, 다른 작업들을 잠시 대기(await)하게 만들기 위함임 (액터 외부에서 액터 내부에 접근하려면 항상 비동기(async)적으로 접근해야 함)

- 그런데 어떻게 액터가 상호 배제를 도와주는 걸까? 외부에서 액터에 접근할 때(= 공유 가변 상태에 접근할 때) 직렬 실행자(serial executor)를 통해 실행을 모두 직렬화시킴, (즉, 한번에 하나씩 실행)
- '직렬'이라는 단어가 붙었다고, 이게 직렬 큐를 의미하는 건 아님. FIFO로 동작하는 게 아니다.

- 데이터베이스나 캐시 등의 목적으로 액터를 주로 사용



- 작업(Task)과 마찬가지로 액터도 독립적인 비동기 컨텍스트로 간주될 수 있음. Task에서 액터로 데이터를 공유할 때도 마찬가지로 Sendable 프로토콜을 준수하는 타입만 공유할 수 있음


### 액터 격리(Actor Isolation)

- `격리`시킨다는 게 무슨 의미일까? 액터 격리(혹은 작업 격리)는 액터의 내부 상태를 프로그램의 나머지 부분으로 보호하는 메커니즘임.

 데이터가 여러 스레드에서 동시에 접근하지 않도록 해당 데이터에 대한 접근 권한을 단독으로 취한다는 의미임. 액터에 격리된 상태는 오직 해당 액터를 통해서만 접근이 가능함. 
 
 외부에서 비동기적으로 액터에 접근하면 액터의 직렬 실행자에 작업이 배정됨
 
 ```swift
 
 ```
 
특정 액터에 격리당한 프로퍼티나 메서드는 액터 내부에서만 동기적으로 접근이 가능함. 이때 FIFO로 동작하는 게 아니라 우선순위의 영향을 받아 Repriority가 될 수 있음 (FIFO인 직렬 디스패치 큐는 우선순위 역전이 발생하면 앞서 위치한 모든 작업의 우선순위를 올리는 방식으로 해결하지만, 이는 근본적인 해결책이 아님)

#### 비격리(non-Isolated)

- '격리'라는 개념이 있다면 '비격리(non-isolated)'라는 개념도 존재하지 않을까? 비격리는 - 격리와 반대로 - 액터의 내부 상태를 프로그램의 나머지 부분으로부터 보호하지 않겠다는 의미임. 즉, 외부에서 언제든지 동기적으로 비격리된 메서드 및 프로퍼티에 접근이 가능함

- 보호될 필요가 없는 - 데이터 경합의 가능성이 없는 데이터의 경우 - 비격리 처리 가능
- 액터 내부의 데이터에 접근하지 않는 메서드도 비격리 처리 가능 

- 프로퍼티 및 메서드를 비격리처리하면, 해당 코드는 액터 내부에 위치하지만, nonisolated 메서드는 액터 외부에 있는 것으로 간주되기 때문에 액터의 변경 가능한 상태를 참조할 수 없습니다.


- 비격리가 필요한 조금 더 다양한 예제를 살펴보겠음, Equtable 프로토콜을 채택하면 정적 동등성 메서드을 구현해야 하는데, 해당 정적 메서드의 경우 인스턴스 데이터에 접근하는 게 아니기 때문에 액터에 격리되면 안됨. 격리될 필요가 없음

```swift

```

- 그리고, 외부에서 동기적으로 호출되어야 하는 메서드의 경우도 비격리로 처리해야 함. 예를 들어, Hashable의 hash(into:) 메서드의 경우 외부에서 동기적으로 호출되어야 하기 때문에 반드시 비격리/동기 함수로 구현해야 함, 따라서 비격리 처리해야 함

```swift

```

- reduce 호출에는 읽기를 수행하는 클로저가 있습니다. readSome 호출에 await이 없다는 것을 주목하세요. 이는 해당 클로저가 액터에 격리된 함수인 read 내부에서 생성되었기 때문이며, 클로저 자체도 액터에 격리되어 있기 때문입니다.

```swift

```


- 액터 내부에서 Detached Task를 만드는 경우, Detached Task는 어느 자원을 상속받지 않는 독립적인 작업 컨텍스트이기 때문에, 이 클로저는 액터에 속할 수 없으며, 그래서 해당 클로저는 액터에 격리되지 않습니다. 그렇지 않으면 데이터 경합이 발생할 수 있습니다. 




### 액터 홉핑(Actor Hopping)

- 한 액터에서 다른 액터로 실행이 전환되는 액터 홉핑(actor hopping) 현상 -> 비효율적인 오버헤드, 스레드 컨텍스트 스위칭이 일어날 수 있음, 적절한 작업과 모델의 설계를 통해 성능 최적화 필요 (액터로 작업하는 것이 무조건적인 장점을 가지는 건 아니다!)


- 실제로는 더 많은 액터가 존재할 수 있습니다. 이러한 액터들은 협력형 스레드 풀에서 실행되며, 피드 액터들은 데이터베이스와 상호작용하면서 기사를 저장하거나 기타 작업을 수행할 수 있습니다. 이 과정에서 한 액터에서 다른 액터로 실행이 전환되는 액터 홉핑(actor hopping) 현상이 발생합니다.

. 첫째, 액터 홉핑이 이루어지는 동안 스레드는 블로킹되지 않았습니다. 둘째, 홉핑을 위해 새로운 스레드를 생성할 필요 없이, 런타임이 스포츠 피드 액터의 작업을 일시 중단하고 데이터베이스 액터를 위한 새로운 작업을 생성하여 실행을 계속할 수 있습니다.

비동기 작업이 많고 특히 경쟁 상태가 심한 경우, 시스템은 어떤 작업이 더 중요한지에 따라 적절한 트레이드-오프를 해야 합니다. 이상적으로는 사용자 상호작용과 관련된 고우선순위 작업이 백업 저장과 같은 백그라운드 작업보다 우선 처리되어야 합니다.

액터 홉핑은 서로 다른 액터(각자 다른 큐/실행 컨텍스트) 간의 호출 때문에, 실행 컨텍스트가 전환되며, 이로 인해 컨텍스트 스위칭이 발생한다! 액터 홉핑 시 “다른 액터의 실행자”로 전환하는 비용

- 가능하면 한 액터에서 많은 양의 일(ImageDataBase + DiskStorage) (ImageDownloader)을 처리하도록 해 액터 홉핑을 가능한 줄이는 게 좋다!



####액터의 원자성(Atomicity)

 - 원자성(atmomicity)는 쪼갤 수 없는 작업의 수행 단위
- 즉, 온전하게 작업을 모두 수행하거나, 아니면 작업을 아예 수행하지 않거나 둘 중 한가지의 결과만 존재해야 함. 데이터가 소실되는 상태가 되어선 안됨

- 액터 내부 상태를 외부에서 바꾸길 원하는 경우, 액터의 격리 메서드에 데이터를 전달하는 방식으로 구현, 그리고 해당 격리 메서드는 외부와의 비동기적 의사소통이 필요없다면 (반드시 다른 async 함수를 호출해야 할 필요가 없다면) 실행 시작부터 끝까지 멈추지 않는 원자성을 유지해야 함

```swift

```

- 외부에서 액터 내부에 격리된 프로퍼티를 직접 수정할 수는 없고, 반드시 액터 내부 격리 메서드에 새로운 값을 전달하는 방식으로 수정해야 함. 이때 가능하면 함수가 일시 중단되지 않고 처음부터 끝까지 멈추지 않고 실행되는 원자적 형태로 구현해야 함

- 액터에서 데이터를 다루는 과정에서 중간에 일시중단되었다가, 다시 재개될 때 현재 상태가 예상했던 것과 달라질 수 있음, - 액터의 재진입성

```swift

```

- 또는, actor 타입 매개변수 앞에 isolated 키워드를 붙이면 해당 전역 함수가 매개변수로 주어진 액터 인스턴스로 격리됨, 외부에 구현되어 있어도 액터 내부에 구현된 격리 메서드마냥 작동되는 특권을 얻음


```swift

```

- actor 타입 매개변수에 isolated 키워드를 붙이면 해당 적역함수가 액터로 격리됨, 외부에 구현되어 있어도, 액터 내부에 구현된 격리 메서드라고 보아도 무방함!

- 액터 내부의 데이터 변경은 액터의 격리 메서드로 구현해야 하고 해당 격리 메서드는 비동기적인 통신이 없다면 중간에 일시중단되면 안됨, 원자성 유지 구현 필요



### 액터의 재진입성(Actor Re-entrancy)

- 액터 재진입은 액터의 외부 비동기적인 작업으로 인해 멈춰 있을 때, 다른 작업이 액터에 접근할 때 발생할 수 있음
- 액터가 외부와의 비동기적 의사소통에 따라, 작업이 멈췄다가 다시 실행될 수 있으므로
해당 비동기 작업 재개시점에 액터의 데이터(shared mutable state)가 바뀌었을 수 있음
따라서, 액터에서 격리 메서드에서도 일시중단 지점에서 이후(await)에는 재진입성을 잘 고려해서 액터 메서드를 설계해야 함

That said, actors do not like to sit around and do nothing. When we call a synchronous function on an actor that function will run start to end with no interruptions; the actor only does one thing at a time.

However, when we introduce an async function that has a suspension point the actor will not sit around and wait for the suspension point to resume. Instead, the actor will grab the next message in its “mailbox” and start making progress on that instead. When the thing we were awaiting returns, the actor will continue working on our original function.

```swift

```

- 액터의 재진입성에 따른 고수준의 데이터 경합을 해겨라는 방법은 (1) 재진입 시점 이후, 기존의 데이터가 바뀌었는지 확인 (2) Task의 상태를 저장하는 방식으로 구현


- 액터의 재진입성(re-entrancy)은 교착 상태(deadlock)를 방지하고 코드가 계속 진행(forward progress)되게 하는 것을 보장하지만, 각 await 지점마다 가정이 유지되는지 확인해야 합니다.
 재진입을 잘 설계하려면 액터 상태의 변경을 동기 코드 내에서 수행해야 합니다. 이상적으로, 모든 상태 변경을 동기 함수 내부에서 수행하게 하여 상태 변경이 캡슐화될 수 있도록 하는 게 좋습니다.
  상태 변경은 일시적으로 액터를 일관되지 않은 상태로 만들 수 있으므로, await 이전에는 반드시 상태의 일관성을 회복해야 합니다.

Actor reentrancy is a feature of actors that can lead to subtle bugs and unexpected results. Due to actor reentrancy we need to be very careful when we’re adding async methods to an actor, and we need to make sure that we think about what can and should happen when we have multiple, reentrant, calls to a specific function on an actor.

Sometimes this is completely fine, other times it’s wasteful but won’t cause problems. Other times, you’ll run into problems that arise due to certain state on your actor being changed while your function was suspended. Every time you await something inside of an actor it’s important that you ask yourself whether you’ve made any state related assumptions before your await that you need to reverify after your await.





#### 액터 경합(Actor Contention)

- 액터 내부에서는 직렬 실행자 때문에 병렬 처리의 성능상 이점을 얻기 힘든 단점도 존재함 (병렬 처리가 필요한 작업은 액터 외부로 보내서 처리해야 함)

- 외부 Task에서 작업을 하다가 정말로 필요한 부분만 액터에서 실행시키도록 하면 좋음, 그래서 가능하면 액터에 접근할 때 가능한 한 작은 단위로 나누어서 접근을 하는 게 좋음

- 

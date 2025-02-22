## How to deadlock in RxSwift:

Step 0:

- Simple observable

```swift
let sharedSubscription = Observable.create { observer in
    observer.on(.next(3))
    return Disposables.create()
}
.share(replay: 1)

let sources = 0...50
let oneSource = Observable.zip(sources.map { _ in
    self.getSomeInfoFromNetwork()
        .flatMap { _ in
            self.sharedSubscription
        }
        .take(1)
})
```

Step 1:

- TakeCount operator tries to emit completion

<img src="res/01 take count tries to complete.png" />


Step 2:

- Zip catches completion and starts disposing of the source sequence


<img src="res/02 zip disposes of the source.png" />


Step 3:
 - This disposal propagates up to `ShareReplay1WhileConnected`
 - And it tries to acquire a lock to unsubscribe

<img src="res/03 shareReplay1WhileConnect tries to lock to unsub.png" />

Step 4: 
- Meanwhile, on a separate thread
- `ShareReplay1WhileConnected` is replaying an event, while being under its own lock

<img src="res/04 another thread has lock of replay 1.png" />
 

Step 5:

- It propagates down to `zip` operator, trying to acquire a lock

<img src="res/05 another thread tries to acquire zip.png" />

Step 6:

- It's a data race, so occasionally the processes can overlap, which can cause two threads to wait on each other.
- More concurrent operations = exponentially higher chances of a deadlock.

And that's how RxSwift deadlocks.

<img src="res/legasov.jpg" />
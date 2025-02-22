//
//  ViewController.swift
//  RxSwiftDeadlock
//
//  Created by i.weisberg on 22/02/2025.
//

import UIKit
//import RxSwift
import Combine

class ViewController: UIViewController {
//    let disposeBag = DisposeBag()
    
    var subscriptions = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentValueSubject = CurrentValueSubject<Int, Never>(3)
        
        let sharedSubscription = currentValueSubject
//            .print("ASDF source sub")
            .multicast { CurrentValueSubject<Int, Never>(3) }
        
        let sources = 0...50
        
        let source = self.getSomeInfoFromNetwork()
            .flatMap { _ in
                sharedSubscription
            }
//            .print("ASDF get info")
            .eraseToAnyPublisher()
        
//        let resultingZip = source.zip(source)
        let resultingZip = source
            .zip(source)
            .zip(source)
            .zip(source)
            .zip(source)
            .zip(source)
//            .zip(source) //  comment-outable
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//            .zip(source)
//
//        for _ in 1..<sources.count {
//            resultingZip = resultingZip.zip(source).eraseToAnyPublisher()
//        }
//        let oneSource = Publishers.ZipMany<Int, Never>(sources.map { index in
//            self.getSomeInfoFromNetwork()
//                .flatMap { _ in
//                    sharedSubscription
//                }
////                .print("ASDF \(index)")
////                .prefix(1)
//                .eraseToAnyPublisher()
//        })
        
//
        
        resultingZip
//            .print("ASDF derived sub")
            .sink(receiveCompletion: { [unowned self] _ in
                print("ASDF in completion")
                DispatchQueue.main.async { [unowned self] in
                    self.view.backgroundColor = .systemGreen
                }
            }, receiveValue: { p in
                print("ASDF receiving value", p)
            })
            .store(in: &subscriptions)
        
        
        sharedSubscription.connect()
            .store(in: &subscriptions)
        
//        let sharedSubscription = Observable.create { observer in
//            observer.on(.next(3))
//            return Disposables.create()
//        }
//        .share(replay: 1)
//        
//        let sources = 0...50
//        let oneSource = Observable.zip(sources.map { _ in
//            self.getSomeInfoFromNetwork()
//                .flatMap { _ in
//                    sharedSubscription
//                }
//                .take(1)
//        })
//        
//        oneSource
//            .debug("ASDF")
//            .subscribe(onCompleted: { [unowned self] in
//                DispatchQueue.main.async { [unowned self] in
//                    self.view.backgroundColor = .systemGreen
//                }
//            })
//            .disposed(by: disposeBag)
        
        
    }
    
//    func getSomeInfoFromNetwork() -> Observable<Void> {
//        Observable.just(())
//            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
//    }
//    
    func getSomeInfoFromNetwork() -> AnyPublisher<Void, Never> {
        Just(())
            .delay(for: 1, scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}

struct CreateObserver<Output, Failure: Error> {
    let onNext: ((Output) -> Void)
    let onError: ((Failure) -> Void)
    let onComplete: (() -> Void)
}

struct Disposable {
    let dispose: () -> Void
}

extension AnyPublisher {
    static func create(subscribe: @escaping (CreateObserver<Output, Failure>) -> Disposable) -> Self {
        let subject = PassthroughSubject<Output, Failure>()
        var disposable: Disposable?
        return subject
            .handleEvents(receiveSubscription: { subscription in
                disposable = subscribe(CreateObserver(
                    onNext: { output in subject.send(output) },
                    onError: { failure in subject.send(completion: .failure(failure)) },
                    onComplete: { subject.send(completion: .finished) }
                ))
            }, receiveCancel: { disposable?.dispose() })
            .eraseToAnyPublisher()
    }
}
                                                    

extension Publishers {
    struct ZipMany<Element, F: Error>: Publisher {
        typealias Output = [Element]
        typealias Failure = F

        private let upstreams: [AnyPublisher<Element, F>]

        init(_ upstreams: [AnyPublisher<Element, F>]) {
            self.upstreams = upstreams
        }

        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let initial = Just<[Element]>([])
                .setFailureType(to: F.self)
                .eraseToAnyPublisher()

            let zipped = upstreams.reduce(into: initial) { result, upstream in
                result = result.zip(upstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }

            zipped.subscribe(subscriber)
        }
    }
}

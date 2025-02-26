//
//  ViewController.swift
//  RxSwiftDeadlock
//
//  Created by i.weisberg on 22/02/2025.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedSubscription = Observable.create { observer in
            observer.on(.next(3))
            return Disposables.create()
        }
        .multicast(PublishSubject())
        .refCount()
        
        let sources = 0..<100
        let resultsAsArray = Observable.merge(sources.map { _ in
            self.getSomeInfoFromNetwork()
                .flatMap { _ in
                    sharedSubscription
                }
                .take(1)
                .timeout(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .catch { _ in .empty() }
        })
        .debug("ASDF")
        .toArray()
        
        resultsAsArray
            .subscribe(onSuccess: { [unowned self] results in
                assert(results.count == sources.upperBound)
                DispatchQueue.main.async { [unowned self] in
                    self.view.backgroundColor = .systemGreen
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getSomeInfoFromNetwork() -> Observable<Void> {
        Observable.just(())
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
    }
}

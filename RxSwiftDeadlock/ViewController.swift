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
    
    
    let sharedSubscription = Observable.create { observer in
        observer.on(.next(3))
        return Disposables.create()
    }
    .share(replay: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sources = 0...100
        let oneSource = Single.zip(sources.map { _ in
            self.getSomeInfoFromNetwork()
                .flatMap { _ in
                    self.sharedSubscription
                }
                .flatMap { int in
                    Single.just(int)
                }
                .take(1)
                .asSingle()
        })
        
        oneSource
            .debug("ASDF")
            .subscribe(onSuccess: { [unowned self] _ in
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

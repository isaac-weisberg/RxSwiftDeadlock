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
        .share(replay: 1)
        
        let sources = 0...50
        let oneSource = Observable.zip(sources.map { _ in
            self.getSomeInfoFromNetwork()
                .flatMap { _ in
                    sharedSubscription
                }
                .flatMap { int in
                    Observable.just(int)
                }
                .take(1)
        })
        
        oneSource
            .debug("ASDF")
            .subscribe(onCompleted: { [unowned self] in
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

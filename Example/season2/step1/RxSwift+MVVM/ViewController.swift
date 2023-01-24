//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    var disposable = DisposeBag() // 이 또한 suger 존재
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    // Utility
    
    // promiseKit - promise - then
    // Bolt - bolt - then
    // RxSwift 비동기적으로 생기는 데이터를 리턴값으로 전달하기 위해
    // (나중에 생기는 데이터 = Obsevable)
    // (나중에 오면 = subscribe) event가 옴 (next, error, completed)
    
    /*
     Observable의 생명 주기
     1. Create (만들어만 놓는것)
     2. Subscribe 됬을 때 동작함
     3. onNext
     ------- 끝 -------
     4. onCompleted / onError
     5. Disposed
     
     create 하고 dispose 하고 다시 뭘 하려고 했을 떄 재사용 안됨
     subscribe를 해야함
     create된 Observable의 첫번째 subscribe랑 Observable의 두번째 subscribe랑은 다름
     */
    
    
    // 함수 분리
    func downloadJson(_ url: String) -> Observable<String> {
//        return Observable.from(["Hello", "World"]) // sugar api
//        return Observable.create { emmiter in
//            emmiter.onNext("Hello World")
//            emmiter.onCompleted()
//            return Disposables.create()
//        }
        
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create { emitter in
            let url = URL(string: url)!

            // URLSession 자체가 메인스레드가 아닌 다른스레드에서 실행됨
            // 따라서 onNext..Error 등 도 urlsession이 처리하고 있는 그 스레드에서 동작함
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }

                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }

            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }

//        return Observable.create() { f in
//            // 그렇다면 completion 말고 return값으로 받을 수 없을까?
//            DispatchQueue.global().async {
//                // 문제는 리턴을 못해서 completion을 사용해야함
//                let url = URL(string: MEMBER_LIST_URL)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    // 본 함수가 끝나고 나서 나  중에 실행되는 함수여서 escaping을 해준다.
//                    // 만약 옵셔널클로저인경우에는 escaping이 default라 안해줘도됨
//                    f.onNext(json)
//                    f.onCompleted() // 순환참조 문제 해g결
//                }
//            }
//            return Disposables.create()
//        }
    }
    
    // MARK: SYNC
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello world")
        
        let d = Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0}
            .observeOn(MainScheduler.instance)
            .subscribe(){ json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            }
        disposable.insert(d)
        
        // 비동기: 현재 작업은 그대로 진행하고 다른 스레드에서 원하는 작업을 비동기적으로 동시에 수행
        // 다른 스레드에서 멀티스레드로 일을 처리한 다음에 그 결과를 비동기적으로 받아서 처리를 함
        
//        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
//        let disposable = downloadJson(MEMBER_LIST_URL)
//        //   여기서는 self 사용할 때 순환참조가 안생기나? 생긴다!
//        // 순환참조가 생기는 이유는 크로저가 self를 캡처하면서 rc가 증가하기 때문인데
//        // 클로저가 사라지면서 self에 대한 rc도 놓기때문에 감소한다.
//            .debug()
//            .map({ json in json?.count ?? 0 }) // oprator
//            .filter{ cnt in cnt > 0} // oprator
//            .map {"\($0)"} // oprator
//            .observeOn(MainScheduler.instance) // data를 중간에 바꾸는 sugar들을 oprator라고 한다
//        // https://reactivex.io/documentation/operators.html 에 가면 operator를 볼 수 있다.
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
//        // g 후에 observeOn에 다다르면 그 때 부터 observeOn에서 지정한 스레드로 변경됨 (위치 상관 없음)
//            .subscribe { json in
////                DispatchQueue.main. async {
//                    self.editView.text = json
//                    self.setVisibleWithAnimation(self.activityIndicator, false)
////                }
//            }
//            .subscribe { event in
//                switch event {
//                case .next(let json):
//                    // 그래서 urlssesion에서 처리하고 있는 스레드가 main스레드가 아니기 떄문에 Error
//                    DispatchQueue.main.async {
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//
//                case .completed:
//                // ompleted나 error 때에 수행을 다했다 여겨서 클로저가 없어짐 -> rc가 감소함
//                    break
//                case .error:
//                    break
//                }
//            }
        // 취소시킴
        // disposable.dispose()
        
        // 알아야 할 것들
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        
    }
}

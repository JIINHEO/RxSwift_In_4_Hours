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
    
    // 함수 분리
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create() { f in
            // 그렇다면 completion 말고 return값으로 받을 수 없을까?
            DispatchQueue.global().async {
                // 문제는 리턴을 못해서 completion을 사용해야함
                let url = URL(string: MEMBER_LIST_URL)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    // 본 함수가 끝나고 나서 나중에 실행되는 함수여서 escaping을 해준다.
                    // 만약 옵셔널클로저인경우에는 escaping이 default라 안해줘도됨
                    f.onNext(json)
                    f.onCompleted() // 순환참조 문제 해결
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: SYNC
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // 비동기: 현재 작업은 그대로 진행하고 다른 스레드에서 원하는 작업을 비동기적으로 동시에 수행
        // 다른 스레드에서 멀티스레드로 일을 처리한 다음에 그 결과를 비동기적으로 받아서 처리를 함
        
        let disposable = downloadJson(MEMBER_LIST_URL)
        //   여기서는 self 사용할 때 순환참조가 안생기나? 생긴다!
        // 순환참조가 생기는 이유는 크로저가 self를 캡처하면서 rc가 증가하기 때문인데
        // 클로저가 사라지면서 self에 대한 rc도 놓기때문에 감소한다.
            .subscribe { event in
                switch event {
                case .next(let json):
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                    
                case .completed:
                // ompleted나 error 때에 수행을 다했다 여겨서 클로저가 없어짐 -> rc가 감소함
                    break
                case .error:
                    break
                }
            }
        // 취소시킴
//        disposable.dispose()
    }
}

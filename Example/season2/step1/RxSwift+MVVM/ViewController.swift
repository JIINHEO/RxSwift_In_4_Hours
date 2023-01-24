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
    
    // 함수 분리
    func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
        // 그렇다면 completion 말고 return값으로 받을 수 없을까?
        DispatchQueue.global().async {
            // 문제는 리턴을 못해서 completion을 사용해야함
            let url = URL(string: MEMBER_LIST_URL)!
            let data = try! Data(contentsOf: url)
            let json = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                // 본 함수가 끝나고 나서 나중에 실행되는 함수여서 escaping을 해준다.
                // 만약 옵셔널클로저인경우에는 escaping이 default라 안해줘도됨
                completion(json)
            }
        }
    }
    
    // MARK: SYNC
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // 비동기: 현재 작업은 그대로 진행하고 다른 스레드에서 원하는 작업을 비동기적으로 동시에 수행
        // 다른 스레드에서 멀티스레드로 일을 처리한 다음에 그 결과를 비동기적으로 받아서 처리를 함
        
        let json:나중에생기는데이터<String>? = downloadJson(MEMBER_LIST_URL)
        json.나중에생기면 { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }
    }
}

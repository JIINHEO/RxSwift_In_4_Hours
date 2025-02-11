//
//  APIService.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

let MenuUrl = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"

class APIService {
    static func fetchAllMenus(onComplete: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: MenuUrl)!) { data, res, err in
            if let err = err {
                onComplete(.failure(err))
                return
            }
            guard let data = data else {
                let httpResponse = res as! HTTPURLResponse
                onComplete(.failure(NSError(domain: "no data",
                                            code: httpResponse.statusCode,
                                            userInfo: nil)))
                return
            }
            onComplete(.success(data))
        }.resume()
    }
    
    static func fetchAllMenusRx() -> Observable<Data> {
        return Observable.create() { emmiter in
            // 서버에서 받아온 모델과 기존 만들어놓은 모델이 다르다
            // 레거시 코드를 rx로 감싼다
            fetchAllMenus { result in
                switch result {
                case let .success(data):
                    emmiter.onNext(data)
                    emmiter.onCompleted()
                case let .failure(err):
                    emmiter.onError(err)
                }
            }
            
            return Disposables.create()
            
        }
    }
}

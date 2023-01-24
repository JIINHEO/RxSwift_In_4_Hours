//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by jiin heo on 2023/01/24.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    // 데이터 이미 들어갔는데 나중에 subscribe를 했기 때문에 변경 초기값을 갖는 behavior로 변경

    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var itemCount = menuObservable.map { $0.map { $0.count}.reduce(0, +) }
    lazy var totalPrice = menuObservable.map { $0.map { $0.price * $0.count}.reduce(0, +) }
    
    // Subject
    // obserbable 밖에서 값을 control해서 새로운 값을 집어넣어줄 수 있음
    
    init() {
        let menus: [Menu] = [
            Menu(name: "튀김1", price: 100, count: 0),
            Menu(name: "튀김2", price: 100, count: 0),
            Menu(name: "튀김3", price: 100, count: 0),
            Menu(name: "튀김4", price: 100, count: 0),
        ]
        
        menuObservable.onNext(menus)
    }
}

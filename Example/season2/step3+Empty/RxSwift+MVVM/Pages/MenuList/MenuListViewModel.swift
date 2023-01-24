//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by jiin heo on 2023/01/24.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

// 모든 생각과 데이터 처리는 viewModel에서
// 따라서 viewModel만 testCase 돌리는게 좋다
// view에서는 버그가 발생할 일이 별로 없다
class MenuListViewModel {
    // 데이터 이미 들어갔는데 나중에 subscribe를 했기 때문에 변경 초기값을 갖는 behavior로 변경
    
    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var itemCount = menuObservable.map { $0.map { $0.count}.reduce(0, +) }
    lazy var totalPrice = menuObservable.map { $0.map { $0.price * $0.count}.reduce(0, +) }
    
    // Subject
    // obserbable 밖에서 값을 control해서 새로운 값을 집어넣어줄 수 있음
    
    init() {
        _ = APIService.fetchAllMenusRx()
            .map { data in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                return response.menus
            }
            .map { menuItems -> [Menu] in
                return menuItems.map {
                    Menu.fromMenuItems(id: 0, item: $0)
                }
            }
            .take(1)
            .bind(to: menuObservable)
    }
    
    func onOrder() {
        
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    Menu(id:m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1) // 한번만 수행할거야
            .subscribe {
                self.menuObservable.onNext($0)
            }
    }
    
    func chanageCount(item: Menu, increase: Int){
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    if m.id == item.id {
                        return Menu(id:m.id, name: m.name, price: m.price, count: max(m.count + increase, 0))
                    } else {
                        return Menu(id:m.id, name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1) // 한번만 수행할거야
            .subscribe {
                self.menuObservable.onNext($0)
            }
    }
}

//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by jiin heo on 2023/01/24.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation

class MenuListViewModel {
    
    var menus: [Menu] = [
        Menu(name: "튀김1", price: 100, count: 0),
        Menu(name: "튀김2", price: 100, count: 0),
        Menu(name: "튀김3", price: 100, count: 0),
        Menu(name: "튀김4", price: 100, count: 0),
    ]
    
    var itemsCount: Int = 5
    var totalPrice: Int = 10000
    
}

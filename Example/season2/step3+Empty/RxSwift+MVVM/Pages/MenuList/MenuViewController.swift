//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    let cellId = "MenuItemTableViewCell"
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.menuObservable
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
            }
            .disposed(by: disposeBag)
        
        viewModel.itemCount
            .map {"\($0)"}
            .bind(to: itemCountLabel.rx.text)
//            .subscribe {
//                self.itgiemCountLabel.text = $0
//            }
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .scan(0, accumulator: +)
            .map { $0.currencyKR() }
            .bind(to: totalPrice.rx.text)
//            .subscribe {
//                self.totalPrice.text = $0
//            }
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
        
//        viewModel.totalPrice.onNext(100)
        // 그럼 외부에서 값을 넣어줘서 보여줄 수 없을까? -> 그래서 나온게 subject이다.
        
        viewModel.menuObservable.onNext([
            Menu(name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
            Menu(name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3)),
            Menu(name: "changed", price: Int.random(in: 100...1000), count: Int.random(in: 0...3))
        ])
    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.menus.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row]
//        cell.title.text = menu.name
//        cell.price.text = "\(menu.price)"
//        cell.count.text = "\(menu.count)"
//
//        return cell
//    }
//}

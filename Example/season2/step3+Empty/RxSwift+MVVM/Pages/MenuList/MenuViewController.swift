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

// view만 보여준다
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
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.chanageCount(item: item, increase: increase)
                }
                
            }
            .disposed(by: disposeBag)
        
        viewModel.itemCount
            .map {"\($0)"}
//            .catchErrorJustReturn("") // UI에서는 연결이 끊어져서 더이상 아무것도 처리해주지 않으면 안됨 - stream이 끊어지면 안됨
//            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: "")
            .(itemCountLabel.rx.text) // drive는 항상 main thread에서 동작함
//            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .scan(0, accumulator: +)
            .map { $0.currencyKR() }
            .bind(to: totalPrice.rx.text)
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
        viewModel.clearAllItemSelections()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        viewModel.onOrder()
    }
}

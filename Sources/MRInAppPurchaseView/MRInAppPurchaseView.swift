//
//  MRInAppPurchaseView.swift
//  MRInAppPurchaseView
//
//  Created by Marco Ricca on 11/09/2021
//
//  Created for MRInAppPurchaseView in 11/09/2021
//  Using Swift 5.4
//  Running on macOS 11.5.2
//
//  Copyright © 2021 Fast-Devs Project. All rights reserved.
//

import MRInAppPurchaseButton
import SwifterSwift
import UIKit

@objc public protocol MRInAppPurchaseViewDelegate: NSObjectProtocol {
    @objc func inAppPurchaseButtonTapped(inAppPurchase: InAppData)
    @objc optional func accessoryButtonTappedForRowWith(inAppPurchase: InAppData)
}

open class MRInAppPurchaseView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    open var inAppView: MRInAppPurchaseView!
    open weak var delegate: MRInAppPurchaseViewDelegate?
    
    private var tableView = UITableView()
    private var inAppPurchases: [InAppData] = []
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        inAppView = self
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.size.width, height: view.size.height), style: .insetGrouped)
        tableView.backgroundColor = UIColor(named: "Table View Backgound Custom Color")
        tableView.tintColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id_table_cell_in_app_list")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        view = tableView
    }
    
    open func setInAppPurchases(_ inAppPurchases: [InAppData]) {
        self.inAppPurchases = inAppPurchases
    }
    
    deinit {
        debugPrint("MRInAppPurchaseView DEINITIALIZATED!!!!")
    }
    
    // MARK: - UITableView
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inAppPurchases.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_table_cell_in_app_list", for: indexPath)
        let accessoryView = UIStackView(arrangedSubviews: [], axis: .horizontal, spacing: 16, alignment: .center, distribution: .fill)
        let data = inAppPurchases[indexPath.row]
        
        // icon
        cell.imageView?.image = data.icon
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.borderWidth = 1
        cell.imageView?.cornerRadius = 6
        cell.imageView?.borderColor = .lightGray
        cell.imageView?.width = 24
        cell.imageView?.height = 24

        // text
        cell.textLabel?.text = data.title
        
        // info button
        if !data.info.isEmpty {
            let inAppInfoButton = UIButton(type: .infoLight)
            inAppInfoButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            inAppInfoButton.tintColor = .link
            inAppInfoButton.addTarget(self, action: #selector(inAppInfoButtonTapped), for: .touchUpInside)
            inAppInfoButton.tag = indexPath.row
            accessoryView.addArrangedSubview(inAppInfoButton)
        }
        
        // purchase button
        let inAppPurchase = PurchaseButton(frame: CGRect(x: 0, y: 0, width: 95, height: 24))
        inAppPurchase.addTarget(self, action: #selector(inAppPurchaseButtonTapped), for: .touchUpInside)
        inAppPurchase.tag = indexPath.row
        if !data.isPurchasedDisable {
            inAppPurchase.normalColor = .link
            inAppPurchase.isEnabled = true
        } else {
            inAppPurchase.normalColor = .systemGray
            inAppPurchase.isEnabled = false
        }
        inAppPurchase.confirmationColor = .systemGreen
        inAppPurchase.normalTitle = data.purchaseButtonTitle.uppercased()
        inAppPurchase.confirmationTitle = locFromBundle("CONFIRM").uppercased()
        accessoryView.addArrangedSubview(inAppPurchase)
        
        // accessoryView
        if data.info.isEmpty {
            accessoryView.frame = CGRect(x: 0, y: 0, width: 95, height: cell.height)
            cell.accessoryView = accessoryView
        } else {
            accessoryView.frame = CGRect(x: 0, y: 0, width: 24 + 16 + 95, height: cell.height)
            cell.accessoryView = accessoryView
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = colorFromBundle(named: "Table View Cell Backgound Custom Color")
        cell.tintColor = .white
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setNomalStateToPurchaseButtons()
    }
    
    // MARK: - UIScrollView

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNomalStateToPurchaseButtons()
    }
    
    // MARK: - Private functions

    private func setNomalStateToPurchaseButtons() {
        for view in tableView.subviewsRecursive() {
            if view is PurchaseButton {
                let inAppButton = view as! PurchaseButton
                if inAppButton.buttonState == .confirmation {
                    inAppButton.setButtonState(PurchaseButtonState.normal, animated: true)
                }
            }
        }
    }

    // MARK: - IBActions
    
    @IBAction private func inAppInfoButtonTapped(_ button: UIButton) {
        setNomalStateToPurchaseButtons()
        
        let data = inAppPurchases[button.tag]
        showAlert(title: data.title, message: data.info, buttonTitles: [locFromBundle("OKBUTTON")], highlightedButtonIndex: 0)
        delegate?.accessoryButtonTappedForRowWith?(inAppPurchase: data)
    }
    
    @IBAction private func inAppPurchaseButtonTapped(_ button: PurchaseButton) {
        switch button.buttonState {
            case .normal:
                button.setButtonState(.confirmation, animated: true)
            case .confirmation:
                button.setButtonState(.progress, animated: true)
                delegate?.inAppPurchaseButtonTapped(inAppPurchase: inAppPurchases[button.tag])
            case .progress:
                break
            @unknown default:
                break
        }
    }
}

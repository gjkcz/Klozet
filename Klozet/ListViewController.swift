//
//  ListViewController.swift
//  Klozet
//
//  Created by Marek Fořt on 08/09/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit

protocol ListToiletsDelegate {
    var toilets: Array<Toilet> { get set }
    var allToilets: Array<Toilet> { get set }
    var isFilterOpenSelected: Bool { get set }
    var isFilterPriceSelected: Bool { get set }
    var locationDelegate: UserLocation? { get }
    func reloadTable()
    //func startUpdating()
    func updateToilets(toilets: Array<Toilet>)
}


class ListViewController: UIViewController, DirectionsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toilets = [Toilet]()
    var allToilets = [Toilet]()
    
    var isFilterOpenSelected = false
    var isFilterPriceSelected = false
    
    var locationDelegate: UserLocation?
    
    var activityView = ActivityView()
    var activityIndicator = UIActivityIndicatorView()
    
    var didOrderToilets = false
    
    var shownCells = 20
    var listFooterDelegate: ListFooterDelegate?
    
    
    override func viewDidLoad() {
        
        //Save all toilets (needed for filters)
        allToilets = toilets
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.tintColor = UIColor(red: 1.00, green: 0.42, blue: 0.20, alpha: 1.0)
        
        setTableFooter()
        
        //Have not ordered toilets yet, show activityIndicator
        if didOrderToilets == false {
            activityView = ActivityView(view: view)
            activityIndicator = activityView.activityIndicator
        }
        
        _ = ListControllerContainer(view: view, toiletsDelegate: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Deselect selected row
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            guard
                let detailViewController = segue.destination as? DetailViewController,
                let indexPath = tableView.indexPathForSelectedRow
            else {return}
            
            detailViewController.toilet = toilets[indexPath.row]
        }
    }
    
    private func setTableFooter() {
        let listFooterFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        let listFooter = ListFooter(frame: listFooterFrame)
        listFooter.reloadDelegate = self
        listFooterDelegate = listFooter
        
        tableView.tableFooterView = listFooter
        
        //Inset so the footer does not appear below ListController
        tableView.contentInset.bottom = 60
        
        
    }

}

extension ListViewController: ListToiletsDelegate, Reload {
    
    func updateToilets(toilets: Array<Toilet>) {
        self.toilets = toilets
        reloadTable()
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell = getListCell(indexPath: indexPath, tableView: tableView)
        return listCell
    }
    
    
    func getListCell(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        //Cell as ListCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as? ListCell else {return UITableViewCell()}
        
        //Getting toilet for cell
        let toilet = toilets[(indexPath as NSIndexPath).row]
        
        cell.locationDelegate = self.locationDelegate
        cell.fillCellData(toilet)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard shownCells < (toilets.count - 20) else {
            listFooterDelegate?.changeToFooterWithInfo(toiletsCount: toilets.count)
            return toilets.count
        }
        return shownCells
    }
}

protocol Reload {
    func reloadTable()
    var shownCells: Int { get set }
}

protocol ListFooterDelegate {
    func changeToFooterWithInfo(toiletsCount: Int)
}

class ListFooter: UIView, ListFooterDelegate {
    
    let moreButton = UIButton(type: .roundedRect)
    let moreStack = UIStackView()
    let activityIndicator = UIActivityIndicatorView()
    
    var reloadDelegate: Reload?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setMoreStack()
        setMoreButton(moreStack: moreStack)
        
    }
    
    private func setMoreStack() {
        moreStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(moreStack)
        moreStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        moreStack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    private func setMoreButton(moreStack: UIStackView) {
        moreButton.setTitle("Načíst další".localized, for: .normal)
        moreButton.setTitleColor(Colors.pumpkinColor, for: .normal)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        moreButton.addTarget(self, action: #selector(loadMoreToilets), for: .touchUpInside)
        moreStack.addArrangedSubview(moreButton)
    }
    
    private func setActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.color = Colors.pumpkinColor
        activityIndicator.sizeToFit()
    }
    
    func loadMoreToilets() {
        
        //activityIndicator.isHidden = false
        //activityIndicator.startAnimating()
        //moreStack.addArrangedSubview(activityIndicator)
        
        //moreButton.isHidden = true
        //moreStack.removeArrangedSubview(moreButton)
        
        reloadDelegate?.shownCells += 20
        reloadDelegate?.reloadTable()
    }
    
    func changeToFooterWithInfo(toiletsCount: Int) {
        moreButton.removeFromSuperview()
        
        
        let infoLabel = UILabel()
        infoLabel.text = "Záchodů celkem: \(toiletsCount)".localized
        infoLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        infoLabel.textColor = Colors.pumpkinColor
        moreStack.addArrangedSubview(infoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






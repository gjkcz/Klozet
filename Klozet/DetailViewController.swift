//
//  DetailViewController.swift
//  Klozet
//
//  Created by Marek Fořt on 20/09/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var toilet: Toilet?
    
    var widthDimension = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Main Stack View
        let detailStackView = DetailStackView(view: view, navigationController: navigationController)
        
        //ImageView
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ToiletPic")
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        detailStackView.addArrangedSubview(imageView)
        
        //TableView
        let tableView = DetailTableView()
        tableView.delegate = self
        tableView.dataSource = self
        detailStackView.addArrangedSubview(tableView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

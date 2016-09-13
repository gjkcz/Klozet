//
//  ListCell.swift
//  Klozet
//
//  Created by Marek Fořt on 08/09/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

class ListCell: UITableViewCell, FilterOpen, DirectionsDelegate {
    
    //Background for toilet image
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var priceBubble: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var openBubble: UIView!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var mainAddressLabel: UILabel!
    @IBOutlet weak var subaddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationDelegate: UserLocation?
    
    let greenColor = UIColor(red: 0.00, green: 0.75, blue: 0.00, alpha: 1.0)

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setCornerRadius(imageBackground, cornerRadius: 10)
        setCornerRadius(priceBubble, cornerRadius: 7)
        setCornerRadius(openBubble, cornerRadius: 7)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setCornerRadius(view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
    }
    
    func fillCellData(toilet: Toilet) {
        setPriceLabel(toilet.price)
        setOpenLabel(toilet)
        setDistanceLabel(toilet.coordinate)
        
        mainAddressLabel.text = toilet.title
        subaddressLabel.text = toilet.subtitle
        
    }
    
    private func setPriceLabel(price: String) {
        priceLabel.text = price.uppercaseString
        
        //If toilet is for free => green color, otherwise set color to orange
        if price == "Zdarma" {
            priceBubble.backgroundColor = greenColor
        }
        else {
            priceBubble.backgroundColor = Colors.pumpkinColor
        }
    }
    
    private func setOpenLabel(toilet: Toilet) {
        
        //Is toilet open
        if isToiletOpen(toilet) {
            openLabel.text = "OTEVŘENO"
            openBubble.backgroundColor = greenColor
        }
        
        //Toilet is not open
        else {
            openLabel.text = "ZAVŘENO"
            openBubble.backgroundColor = Colors.pumpkinColor
        }
    }
    
    private func setDistanceLabel(coordinate: CLLocationCoordinate2D) {
        getDistance(coordinate)
    }
    
}



//
//  ToiletView.swift
//  Klozet
//
//  Created by Marek Fořt on 07/09/16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ToiletView: MKAnnotationView {
    var ShowDelegate: ShowDelegate?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.annotation = annotation
        self.canShowCallout = true
        self.image = UIImage(named: "Pin")
        
        setCalloutAccessoryView()
    }
    
    func setCalloutAccessoryView() {
        
        //Detailed toilet info button
        let rightButton = UIButton.init(type: .detailDisclosure)
        rightButton.tintColor = .mainOrange
        rightButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        rightCalloutAccessoryView = rightButton

        //Left button with ETA
        leftCalloutAccessoryView = DirectionButton()
        
        //Add target to get directions
        //leftButton.addTarget(self, action: #selector(getDirectionsFromAnnotation), forControlEvents: .TouchUpInside)
    }
    
    
    
    @objc func detailButtonTapped() {
        guard
            let toilet = annotation as? Toilet,
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailVC") as? DetailViewController,
            let ShowDelegate = self.ShowDelegate
        else {return}
        
        viewController.navigationController?.navigationBar.tintColor = .mainOrange
        viewController.toilet = toilet
        
        ShowDelegate.showViewController(viewController: viewController)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//DirectionButton
class DirectionButton: UIButton, DirectionsDelegate, MapsDirections {
    
    var toilet: Toilet?

    var locationDelegate: UserLocation?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 55, height: 50))
        
        self.addTarget(self, action: #selector(callGetDirectionsFunc), for: .touchUpInside)
        
        //BackgroundColor
        backgroundColor = .mainOrange
        
        //Image
        setImage(UIImage(named: "Walking"), for: UIControlState())
        setImage((UIImage(named: "Walking")), for: .highlighted)
        
        //Center image in view, 22 is for image width
        let leftImageInset = (frame.size.width - 22) / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: leftImageInset, bottom: 0, right: leftImageInset)
        
        //Title inset
        titleEdgeInsets = UIEdgeInsets(top: 30, left: -22.5, bottom: 0, right: 0)
        titleLabel?.textAlignment = .center
    }
    
    func setEtaTitle(coordinate: CLLocationCoordinate2D) {

        getEta(coordinate, completion: {eta in
            
            //If titleLabel != nil => title is already set, no need for animation
            guard self.titleLabel?.text == nil else {return}
            
            //Title with attributes
            self.titleLabel?.alpha = 0
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.white]
            self.setAttributedTitle(NSAttributedString(string: eta, attributes: attributes), for: UIControlState())
            self.setAttributedTitle(NSAttributedString(string: eta, attributes: attributes), for: .highlighted)
            
            self.animateETA()
        })
    }
    
    //Animating appearance of ETA title
    fileprivate func animateETA() {
        
        //Start with label rotated upside down to then rotate it to the right angle
        titleLabel?.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 1, 0, 0)
        titleLabel?.sizeToFit()
        
        guard let superview = self.superview else {return}
        
        //layoutIfNeeded after sizeToFit() so I don't animate the position of title only rotation
        superview.layoutIfNeeded()
        
        //Image position after adding title
        //Center image in view, 22 is for image width
        let leftImageInset = (frame.size.width - 22) / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: leftImageInset, bottom: 10, right: leftImageInset)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(), animations: {
            //Rotation - 3D animation
            var perspective = CATransform3DIdentity
            perspective.m34 = -1.0 / 500
            //0, 0, 0, 0 because we want default value (we start this animation with already rotated title)
            self.titleLabel?.layer.transform = CATransform3DConcat(perspective, CATransform3DMakeRotation(0, 0, 0, 0))
            
            //Opacity
            self.titleLabel?.alpha = 1
            
            //Needed to animate imageEdgeInset
            superview.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    @objc func callGetDirectionsFunc(sender: UIButton) {
        guard let toilet = self.toilet else {return}
        getDirections(coordinate: toilet.coordinate)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@objc protocol MapsDirections {
}

extension MapsDirections {
    //Opening Apple maps with directions to the toilet
    func getDirections(coordinate: CLLocationCoordinate2D) {
        let destination = coordinate
        
        // TODO: Pass maps the adress
        let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        destinationMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

//
//  AddToiletViewController.swift
//  Klozet
//
//  Created by Marek Fořt on 1/5/18.
//  Copyright © 2018 Marek Fořt. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddToiletViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, CameraDelegate, UINavigationControllerDelegate, PricePickerViewDelegate {
    
    let pricePickerView = PricePickerView()
    var selectedPrice: String = "Free"
    var toilet: Toilet = Toilet(title: "", subtitle: "", coordinate: CLLocationCoordinate2D(), openTimes: [], price: "", toiletId: 0)
    var tapGestureRecognizer: UITapGestureRecognizer?
    var addToiletCollectionView: UICollectionView?
    var uploadImageType: UploadImageType = .toilet
    var toiletImage: UIImage?
    var hoursImage: UIImage?
    let addToiletViewModel = AddToiletViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Toilet"
        
        view.backgroundColor = .white
        

        let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped))
        let cancelAttributes: [NSAttributedStringKey : Any] = [.font : UIFont.systemFont(ofSize: 17, weight: .medium), .foregroundColor : UIColor.mainOrange]
        cancelBarButtonItem.setTitleTextAttributes(cancelAttributes, for: .normal)
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        
        let addToiletCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        addToiletCollectionView.dataSource = self
        addToiletCollectionView.delegate = self
        addToiletCollectionView.backgroundColor = .white
        addToiletCollectionView.register(MapCollectionViewCell.self, forCellWithReuseIdentifier: "mapCell")
        addToiletCollectionView.register(LocationDetailCollectionViewCell.self, forCellWithReuseIdentifier: "locationDetails")
        addToiletCollectionView.register(AddToiletCollectionViewCell.self, forCellWithReuseIdentifier: "addToiletCell")
        addToiletCollectionView.register(PriceCollectionViewCell.self, forCellWithReuseIdentifier: "priceCell")
        view.addSubview(addToiletCollectionView)
        addToiletCollectionView.heightAnchor.constraint(equalToConstant: 435).isActive = true
        addToiletCollectionView.pinToViewHorizontally(view)
        addToiletCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.addToiletCollectionView = addToiletCollectionView

        
        let proxyView = UIView()
        view.addSubview(proxyView)
        proxyView.pinToViewHorizontally(view)
        proxyView.topAnchor.constraint(equalTo: addToiletCollectionView.bottomAnchor).isActive = true
        proxyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        let addToiletButton = UIButton()
        addToiletButton.backgroundColor = .mainOrange
        addToiletButton.setTitle("Add Toilet", for: .normal)
        addToiletButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        addToiletButton.addTarget(self, action: #selector(addToiletButtonTapped), for: .touchUpInside)
        view.addSubview(addToiletButton)
        addToiletButton.centerInView(proxyView)
        addToiletButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addToiletButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        addToiletButton.layer.cornerRadius = 22
        
        
        pricePickerView.pricePickerViewDelegate = self
        pricePickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pricePickerView)
        pricePickerView.pinToViewHorizontally(view)
        pricePickerView.pickerStackBottomAnchor = pricePickerView.topAnchor.constraint(equalTo: view.bottomAnchor)
        pricePickerView.pickerStackBottomAnchor?.isActive = true
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        addToiletCollectionView?.reloadItems(at: [IndexPath(row: 0, section: 0)])
    
    }
    
    @objc private func cancelBarButtonTapped() {
        
        //TODO: Alert when some info filled in?
        dismiss(animated: true, completion: nil)
    }
    
    func dismissPicker() {
        pricePickerView.pickerStackBottomAnchor?.isActive = false
        pricePickerView.pickerStackBottomAnchor = pricePickerView.topAnchor.constraint(equalTo: view.bottomAnchor)
        pricePickerView.pickerStackBottomAnchor?.isActive = true
        
        addToiletCollectionView?.reloadItems(at: [IndexPath(row: 2, section: 0)])
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func addToiletButtonTapped() {
        
        uploadToilet()
        
        //TODO: Tell user if upload succeded or not
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToilet() {
        toilet.price = selectedPrice
        guard let locationDetailsCell = addToiletCollectionView?.dequeueReusableCell(withReuseIdentifier: "locationDetails", for: IndexPath(row: 1, section: 0)) as? LocationDetailCollectionViewCell else {return}
        toilet.subtitle = locationDetailsCell.locationDetailTextView.text
        addToiletViewModel.uploadToilet(toilet, hoursImage: hoursImage, toiletImage: toiletImage).start()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        finishPicking(toilet: toilet, info: info, completion:  { [weak self] image, _ in
            self?.saveImage(image)
        })
    }
    
    private func saveImage(_ image: UIImage) {
        print(image)
        if uploadImageType == .hours {
            hoursImage = image
        }
        else {
            toiletImage = image
        }
    }
}

extension AddToiletViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath.row {
        case 0:
            let mapCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as! MapCollectionViewCell
            mapCell.toilet = toilet
            mapCell.centerToToilet()
            cell = mapCell
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationDetails", for: indexPath) as! LocationDetailCollectionViewCell
        case 2:
            let priceToiletCell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceCell", for: indexPath) as! PriceCollectionViewCell
            priceToiletCell.tappableCellView.cellViewLabel.text = "Price"
            priceToiletCell.priceLabel.text = selectedPrice
            cell = priceToiletCell
        case 3...4:
            let addToiletCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addToiletCell", for: indexPath) as! AddToiletCollectionViewCell
            addToiletCell.tappableCellView.cellViewLabel.text = indexPath.row == 3 ? "Add photo of hours" : "Add photo of toilet"
            cell = addToiletCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
    
}

extension AddToiletViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        switch indexPath.row {
        case 0:
            let addMapViewController = AddMapToiletViewController()
            addMapViewController.toilet = toilet
            navigationController?.pushViewController(addMapViewController, animated: true)
        case 2:
            showPricePickerView()
        case 3:
            uploadImageType = .hours
            uploadImage()
        case 4:
            uploadImageType = .toilet
            uploadImage()
        default: break
        }
    }
    
    func showPricePickerView() {
        dismissKeyboard()
        guard let priceIndex = pricePickerView.prices.index(of: selectedPrice) else {return}
        pricePickerView.pricePicker.selectRow(pricePickerView.prices.endIndex - priceIndex - 1, inComponent: 0, animated: false)
        pricePickerView.pickerStackBottomAnchor?.isActive = false
        pricePickerView.pickerStackBottomAnchor = pricePickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        pricePickerView.pickerStackBottomAnchor?.isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension AddToiletViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat
        switch indexPath.row {
        case 0: height = AppDelegate.isScreenSmall ? 163 : 223
        case 1: height = 105
        case 2...4: height = 53
        default: height = 100
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

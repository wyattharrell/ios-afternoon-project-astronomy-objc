//
//  PhotosViewController.swift
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var previousSolButton: UIBarButtonItem!
    @IBOutlet var nextSolButton: UIBarButtonItem!
    @IBOutlet var cameraSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    let photoController = WHLPhotoController()
    var hasFinished: Bool = false
    var hasPhotoFinished: Bool = false
    var arrayOfFilters: [Photo] = []
    var sol: Int = 0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        previousSolButton.isEnabled = false
        
        photoController.fetchManifest { (error) in
            if let error = error {
                NSLog("Error fetching manifest \(error)")
                return
            }
            
            self.hasFinished = true
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setupSegmentedControl()
                self.title = "Sol \(Int((self.photoController.manifests[self.sol] as! WHLManifest).solID))"
            }
            
            self.photoController.fetchSol(by: self.photoController.manifests[self.sol] as! WHLManifest) { (error) in
                if let error = error {
                    NSLog("Error fetching manifest \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.hasPhotoFinished = true
                }
                
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoDetailSegue" {
            guard let photoDetailVC = segue.destination as? PhotoDetailViewController else { return }
            guard let selected = collectionView.indexPathsForSelectedItems else { return }
            
            if arrayOfFilters.count != 0 {
                photoDetailVC.photo = arrayOfFilters[selected[0].row]
            } else {
                photoDetailVC.photo = (photoController.photos[selected[0].row] as! Photo)
            }
            
            photoDetailVC.photoController = photoController
        }
    }
    
    // MARK: - Private Methods
    private func setupSegmentedControl() {
        cameraSegmentedControl.removeAllSegments()
        
        var i = 1
        cameraSegmentedControl.insertSegment(withTitle: "NONE", at: 0, animated: true)
        for item in (photoController.manifests[sol] as! WHLManifest).cameras {
            cameraSegmentedControl.insertSegment(withTitle: item, at: i, animated: true)
            i += 1
        }
    }
    
    // MARK: - IBActions
    @IBAction func previousSolButtonTapped(_ sender: Any) {
        if hasFinished {
            
            hasPhotoFinished = false
            
            if self.sol != 0 {
                self.sol -= 1
                self.setupSegmentedControl()
                self.title = "Sol \(Int((self.photoController.manifests[self.sol] as! WHLManifest).solID))"
            }
            
            photoController.fetchSol(by: self.photoController.manifests[self.sol] as! WHLManifest) { (error) in
                if let error = error {
                    NSLog("Error fetching manifest \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.hasPhotoFinished = true
                }
            }
        }
        if sol == 0 {
            previousSolButton.isEnabled = false
        }
    }
    
    @IBAction func nextSolButtonTapped(_ sender: Any) {
        if hasFinished, sol < Int((self.photoController.manifests.count - 1)) {
            
            self.sol += 1
            hasPhotoFinished = false
            self.title = "Sol \(Int((self.photoController.manifests[self.sol] as! WHLManifest).solID))"
            self.previousSolButton.isEnabled = true
            self.setupSegmentedControl()

            photoController.fetchSol(by: self.photoController.manifests[self.sol] as! WHLManifest) { (error) in
                if let error = error {
                    NSLog("Error fetching manifest \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.hasPhotoFinished = true
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    @IBAction func cameraSegmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            arrayOfFilters.removeAll()
            collectionView.reloadData()
        } else {
            let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
            arrayOfFilters.removeAll()
            for photo in photoController.photos {
                let photo = photo as! Photo
                
                if photo.cameraName == title {
                    arrayOfFilters.append(photo)
                }
                
            }
            collectionView.reloadData()
        }
    }
    
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayOfFilters.count != 0 {
            return arrayOfFilters.count
        } else if hasFinished {
            return Int((photoController.manifests[sol] as! WHLManifest).photoCount)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.imageView.image = UIImage(named: "placeholder_image")
        cell.imageBackgroundView.layer.cornerRadius = 8
        cell.imageBackgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.imageBackgroundView.layer.shadowOpacity = 1
        cell.imageBackgroundView.layer.shadowOffset = .zero
        cell.imageBackgroundView.layer.shadowRadius = 3
        cell.imageBackgroundView.layer.masksToBounds = false
        cell.imageBackgroundView.backgroundColor = UIColor.white
        cell.imageView.layer.cornerRadius = 8
        cell.imageView.clipsToBounds = true
        if arrayOfFilters.count != 0 {
            
            cell.textLabel.text = arrayOfFilters[indexPath.row].cameraName
            
            cell.photo = arrayOfFilters[indexPath.row]
            cell.photoController = photoController
            
        } else if hasPhotoFinished {
            cell.textLabel.text = (photoController.photos[indexPath.row] as! Photo).cameraName
            
            cell.photo = (photoController.photos[indexPath.row] as! Photo)
            cell.photoController = photoController
        }
                
        return cell
    }
}

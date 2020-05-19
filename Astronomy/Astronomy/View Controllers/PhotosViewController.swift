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
    let cache = NSCache<NSNumber, Photo>()
    var hasFinished: Bool = false
    var hasPhotoFinished: Bool = false
    var arrayOfFilters: [Photo] = []
    var sol: Int = 2
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraSegmentedControl.isEnabled = false
        previousSolButton.isEnabled = false
        setupCollectionViewCells()
        networkRequest()
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
    private func networkRequest() {
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
                    self.cameraSegmentedControl.isEnabled = true
                }
            }
        }
    }
    
    private func setupSegmentedControl() {
        cameraSegmentedControl.removeAllSegments()
        
        var i = 1
        cameraSegmentedControl.insertSegment(withTitle: "NONE", at: 0, animated: true)
        for item in (photoController.manifests[sol] as! WHLManifest).cameras {
            cameraSegmentedControl.insertSegment(withTitle: item, at: i, animated: true)
            i += 1
        }
        cameraSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupCollectionViewCells() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cols: CGFloat = 2
            let spacing: CGFloat = 2
            let edge = (collectionView.bounds.width - spacing * (cols - 1)) / cols
            flowLayout.itemSize.width = edge
            flowLayout.itemSize.height = edge
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.minimumLineSpacing = spacing
            flowLayout.sectionInset = .zero
        }
    }
    
    // MARK: - IBActions
    @IBAction func previousSolButtonTapped(_ sender: Any) {
        if hasFinished {
            
            hasPhotoFinished = false
            cameraSegmentedControl.isEnabled = false
            
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
                    self.cameraSegmentedControl.isEnabled = true
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
            cameraSegmentedControl.isEnabled = false
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
                    self.cameraSegmentedControl.isEnabled = true
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
        
        if arrayOfFilters.count != 0 {
            cell.textLabel.text = "\(arrayOfFilters[indexPath.row].photoID)"
            loadImage(forCell: cell, forPhoto: arrayOfFilters[indexPath.row])
        } else if hasPhotoFinished {
            cell.textLabel.text = "\((photoController.photos[indexPath.row] as! Photo).photoID)"
            loadImage(forCell: cell, forPhoto: (photoController.photos[indexPath.row] as! Photo))
        }
                
        return cell
    }
    
    private func loadImage(forCell cell: PhotoCollectionViewCell, forPhoto photo: Photo) {
        photoController.fetchSinglePhoto(with: photo.imgSrc) { (error, image) in
            if let error = error {
                NSLog("Error fetching photo \(error)");
                return
            }
            
            if let image = image {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

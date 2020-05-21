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
    var sol: Int = 2
    let cache = NSCache<NSNumber, UIImage>()
    var operationsDict: [Int : Operation] = [:]
    let photoFetchQueue = OperationQueue()

    // MARK: - Hector testing
    var cancelCells:[Photo] = []

    
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
            
//            self.hasFinished = true
            
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
                    self.hasFinished = true
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
            self.arrayOfFilters.removeAll()
            cameraSegmentedControl.isEnabled = false
            
            if self.sol != 0 {
                self.sol -= 1
                self.setupSegmentedControl()
                self.title = "Sol \(Int((self.photoController.manifests[self.sol] as! WHLManifest).solID))"
            }

            // MARK: - Copy the current set of photos into an array so that they may be cancelled from this array.
            // Could use an array of Ints instead, and map the photo array by IDs
            cancelCells = photoController.photos as! [Photo]
            photoController.fetchSol(by: self.photoController.manifests[self.sol] as! WHLManifest) { (error) in
                if let error = error {
                    NSLog("Error fetching manifest \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.hasPhotoFinished = true
                    self.hasFinished = true
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
            self.arrayOfFilters.removeAll()
            hasPhotoFinished = false
            cameraSegmentedControl.isEnabled = false

            self.title = "Sol \(Int((self.photoController.manifests[self.sol] as! WHLManifest).solID))"
            self.previousSolButton.isEnabled = true
            self.setupSegmentedControl()

            // MARK: - Copy the current set of photos into an array so that they may be cancelled from this array.
            // Could use an array of Ints instead, and map the photo array by IDs
            cancelCells = photoController.photos as! [Photo]
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
        } else if photoController.manifests.count != 0 {
            return Int((photoController.manifests[sol] as! WHLManifest).photoCount)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        if arrayOfFilters.count != 0 {
            cell.textLabel.text = "\(arrayOfFilters[indexPath.row].photoID)"
            loadImage(at: cell, with: indexPath, for: arrayOfFilters[indexPath.row])
        } else if hasPhotoFinished && hasFinished {
            cell.textLabel.text = "\((photoController.photos[indexPath.row] as! Photo).photoID)"
            loadImage(at: cell, with: indexPath, for: (photoController.photos[indexPath.row] as! Photo))
        }
                
        return cell
    }
    
    private func loadImage(at cell: PhotoCollectionViewCell, with indexPath: IndexPath, for photo: Photo) {
        let photoID = NSNumber(value: photo.photoID)
        
        if let cachedVersion = cache.object(forKey: photoID) {
            cell.imageView.image = cachedVersion
        } else {
            let fetchPhotoOperation = FetchPhotoOperation(reference: photo)
        
            let cacheImageData = BlockOperation {
                let image = UIImage(data: fetchPhotoOperation.imageData)
                if let image = image {
                    self.cache.setObject(image, forKey: photoID)
                }
            }
            
            let finalBlock = BlockOperation {
                if let cachedImage = self.cache.object(forKey: photoID) {
                    cell.imageView.image = cachedImage
                }
            }
            
            cacheImageData.addDependency(fetchPhotoOperation)
            finalBlock.addDependency(cacheImageData)
            
            photoFetchQueue.addOperations([cacheImageData, fetchPhotoOperation], waitUntilFinished: false)
            OperationQueue.main.addOperation(finalBlock)
            
            operationsDict[photo.photoID] = fetchPhotoOperation
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Initial Bug: This method gets called on launch for whatever reason. My assumption is that the cells get loaded before getting customized, and once they get resized some are pushed out of view and therefore dequeued.

        // Check if we have any cells to cancel and then use this array to cancel all the cells.
        if cancelCells.count != 0 {
            let photoId = cancelCells[indexPath.item].photoID
            if let op = operationsDict[photoId] {
                op.cancel()
            }
        }

    }
}

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
    
    // MARK: - Properties
    let photoController = WHLPhotoController()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoController.fetchManifest { (error) in
            if let error = error {
                NSLog("Error fetching manifest \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                NSLog("# of Manifests: \(self.photoController.manifests.count)")
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoDetailSegue" {
            guard let photoDetailVC = segue.destination as? PhotoDetailViewController else { return }
            guard let selected = collectionView.indexPathsForSelectedItems else { return }
            // photoDetailVC.photo = controller.photos[selected[0].row]
            photoDetailVC.photoController = photoController
        }
    }

}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoController.manifests.count
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
        
        // Pass object to cell here
        
        return cell
    }
}

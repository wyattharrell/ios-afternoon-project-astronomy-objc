//
//  PhotoDetailViewController.swift
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var roverLabel: UILabel!
    @IBOutlet var solLabel: UILabel!
    @IBOutlet var cameraLabel: UILabel!
    
    // MARK: - Properties
    let photoController = WHLPhotoController()
    var photo: Photo? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateViews()
        testFetch()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        saveButton.layer.cornerRadius = 8
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.shadowColor = UIColor.lightGray.cgColor
        backgroundView.layer.shadowOpacity = 1
        backgroundView.layer.shadowOffset = .zero
        backgroundView.layer.shadowRadius = 8
        imageView.layer.cornerRadius = 8
        backgroundView.layer.masksToBounds = false
        backgroundView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
    }
    
    private func testFetch() {
        let url = URL(string: "https://mars.nasa.gov/msl-raw-images/proj/msl/redops/ods/surface/sol/00012/opgs/edr/ccam/CR0_398560983EDR_F0030004CCAM03012M_.JPG")!
        photoController.fetchSinglePhoto(with: url) { (error, image) in
            if let error = error {
                NSLog("Error fetching photo: \(error)")
            }
            
            if let image = image {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func savePhoto(with image: UIImage) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("Error saving photo: \(error)")
                        return
                    }
                    
                    if success {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Success!", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Cannot save image", message: "Astronomy does not have access to your Photo Library. Please change this in Settings if you would like to save images.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                break
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let image = imageView.image else { return }
        savePhoto(with: image)
    }
    
}

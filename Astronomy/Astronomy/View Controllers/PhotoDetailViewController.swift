//
//  PhotoDetailViewController.swift
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var roverLabel: UILabel!
    @IBOutlet var solLabel: UILabel!
    @IBOutlet var cameraLabel: UILabel!
    
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
        if isViewLoaded {
            
        }
    }
    
}

//
//  Photo.swift
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import Foundation

@objc class Photo: NSObject {
    @objc let sol: Int
    @objc let cameraName: String
    @objc let cameraFullName: String
    @objc let photoDate: Date
    @objc let imgSrc: URL
    @objc let roverID: Int
    @objc let roverName: String

    @objc init(sol: Int, cameraName: String, cameraFullName: String, photoDate: Date, imgSrc: URL, roverID: Int, roverName: String) {
        self.sol = sol
        self.cameraName = cameraName
        self.cameraFullName = cameraFullName
        self.photoDate = photoDate
        self.imgSrc = imgSrc
        self.roverID = roverID
        self.roverName = roverName
    }
}

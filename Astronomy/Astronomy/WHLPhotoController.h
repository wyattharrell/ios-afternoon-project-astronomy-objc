//
//  WHLPhotoController.h
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;
@class UIImage;
@class WHLManifest;
@interface WHLPhotoController : NSObject

// MARK:- Properties
@property (nonatomic, readonly, nonnull) NSMutableArray<Photo *> *photos;
// MARK:- QUESTION FOR JON: Why does this --v-- still require us to cast the elements of the array.
@property (nonatomic, readonly, nonnull) NSMutableArray<WHLManifest *> *manifests;

// MARK:- Methods
- (void)fetchSinglePhotoWithURL:(NSURL *_Nonnull)imgSrc
                completionBlock:(void (^_Nonnull)(NSError * _Nullable error, UIImage * _Nullable image))completionBlock;

- (void)fetchManifest:(void (^_Nonnull)(NSError * _Nullable error))completionBlock;

- (void)fetchSolByManifest:(WHLManifest *_Nonnull)manifest completionBlock:(void (^_Nonnull)(NSError * _Nullable error))completionBlock;

@end

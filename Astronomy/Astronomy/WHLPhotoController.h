//
//  WHLPhotoController.h
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Photo;
@interface WHLPhotoController : NSObject

@property (nonatomic, readonly, nonnull) NSMutableArray<Photo *> *photos;

@end

NS_ASSUME_NONNULL_END

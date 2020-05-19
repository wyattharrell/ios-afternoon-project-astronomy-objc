//
//  FetchPhotoOperation.h
//  Astronomy
//
//  Created by Karen Rodriguez on 5/19/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Photo;
@interface FetchPhotoOperation : NSOperation

@property (nonatomic) Photo *photoReference;
@property (nonatomic) NSData *imageData;
@property (nonatomic) NSURLSessionDataTask *task;

- (instancetype) initWithReference:(Photo *)photo;
@end

NS_ASSUME_NONNULL_END

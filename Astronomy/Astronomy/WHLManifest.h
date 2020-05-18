//
//  WHLManifest.h
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WHLManifest : NSObject

@property (nonatomic, readonly) int solID;
@property (nonatomic, readonly) int photoCount;
@property (nonatomic, readonly, copy) NSArray<NSString *> *cameras;

- (instancetype)initWithSolID:(int)solID
                   photoCount:(int)photoCount
                      cameras:(NSArray<NSString *> *)cameras;

@end

NS_ASSUME_NONNULL_END

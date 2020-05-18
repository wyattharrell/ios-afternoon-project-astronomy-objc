//
//  WHLManifest.m
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "WHLManifest.h"

@implementation WHLManifest
- (instancetype)initWithSolID:(int)solID photoCount:(int)photoCount cameras:(NSArray<NSString *> *)cameras {
    self = [super init];
    if (self) {
        _solID = solID;
        _photoCount = photoCount;
        _cameras = [cameras copy];
    }
    return self;
}
@end

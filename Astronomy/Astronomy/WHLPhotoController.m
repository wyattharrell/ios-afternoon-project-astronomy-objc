//
//  WHLPhotoController.m
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "WHLPhotoController.h"
#import "Astronomy-Bridging-Header.h"


@implementation WHLPhotoController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _photos = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

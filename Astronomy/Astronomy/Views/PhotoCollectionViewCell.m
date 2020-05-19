//
//  PhotoCollectionViewCell.m
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "WHLPhotoController.h"
#import "Astronomy-Swift.h"

@implementation PhotoCollectionViewCell

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.photoController fetchSinglePhotoWithURL:self.photo.imgSrc completionBlock:^(NSError * _Nullable error, UIImage * _Nullable image) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
        
    }];
}


@end

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

    _imageBackgroundView.layer.cornerRadius = 8;
    _imageBackgroundView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _imageBackgroundView.layer.shadowOpacity = 1;
    _imageBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _imageBackgroundView.layer.shadowRadius = 3;
    _imageBackgroundView.layer.masksToBounds = NO;
    _imageBackgroundView.backgroundColor = [UIColor whiteColor];
    _imageView.layer.cornerRadius = 8;
    _imageView.clipsToBounds = YES;

}


@end

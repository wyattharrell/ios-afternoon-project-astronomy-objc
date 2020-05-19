//
//  PhotoCollectionViewCell.h
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WHLPhotoController;
@class Photo;

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) WHLPhotoController *photoController;
@property (nonatomic, assign) Photo *photo;
@property (strong, nonatomic) IBOutlet UIView *imageBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

NS_ASSUME_NONNULL_END

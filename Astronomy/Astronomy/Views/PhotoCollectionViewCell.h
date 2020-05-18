//
//  PhotoCollectionViewCell.h
//  Astronomy
//
//  Created by Wyatt Harrell on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *imageBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END

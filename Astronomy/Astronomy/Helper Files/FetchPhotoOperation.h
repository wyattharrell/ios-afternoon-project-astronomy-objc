//
//  FetchPhotoOperation.h
//  Astronomy
//
//  Created by Karen Rodriguez on 5/19/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FetchPhotoOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

@end

NS_ASSUME_NONNULL_END

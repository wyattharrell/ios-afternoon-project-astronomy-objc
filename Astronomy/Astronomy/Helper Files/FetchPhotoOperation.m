//
//  FetchPhotoOperation.m
//  Astronomy
//
//  Created by Karen Rodriguez on 5/19/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "FetchPhotoOperation.h"
#import "Astronomy-Swift.h"

@interface FetchPhotoOperation()

@property BOOL executing;
@property BOOL finished;
//@property BOOL cancelled;
@property BOOL asynchronous;

@end

@implementation FetchPhotoOperation

@synthesize executing = _executing;
@synthesize finished = _finished;
//@synthesize cancelled = _cancelled;
@synthesize asynchronous = _asynchronous;

- (instancetype)initWithReference:(Photo *)photo {
    self = [super init];
    if (self) {
        _photoReference = photo;
        _imageData = nil;
        _asynchronous = YES;
    }
    return self;
}

- (void)start {
    // Tell observers we about to change this
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = YES;
    // Let observers know we changed this
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    self.task = [NSURLSession.sharedSession dataTaskWithURL:self.photoReference.imgSrc completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Inside of FetchPhotoOperation with url: %@", self.photoReference.imgSrc);
        if (error) {
            NSLog(@"Error fetching image for photo: %@", self.photoReference);
            [self willChangeValueForKey:@"isFinished"];
            self.finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            return;
        }

        self.imageData = data;

        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }];
    [self.task resume];
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [self.task cancel];
    [super cancel];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self.executing;
}

- (BOOL)isFinished {
    return self.finished;
}
//
//- (BOOL)isCancelled {
//    return _cancelled;
//}
@end

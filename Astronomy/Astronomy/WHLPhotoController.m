//
//  WHLPhotoController.m
//  Astronomy
//
//  Created by Karen Rodriguez on 5/18/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "WHLPhotoController.h"
#import <UIKit/UIKit.h>
#import "Astronomy-Bridging-Header.h"
#import "LSIErrors.h"
#import "Photo.swift"

NSString *baseURLString = @"https://api.nasa.gov/mars-photos/api/v1/";
NSString *apiKey = @"3MYY5NPWds1kZu7B3B7In88FKEHYXncJQkgBFNr6";

@interface WHLPhotoController ()

@property (nonatomic, readonly, nonnull) NSDateFormatter *dateFormatter;

@end

@implementation WHLPhotoController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _photos = [[NSMutableArray<Photo *> alloc] init];
        _manifests = [[NSMutableArray<WHLManifest *> alloc] init];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        _dateFormatter = formatter;

    }
    return self;
}

- (void)fetchSinglePhotoWithURL:(NSURL *)imgSrc
                completionBlock:(void (^)(NSError * _Nullable error, UIImage * _Nullable image))completionBlock{

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:imgSrc completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Inside of datatask completionHandler with url: %@", imgSrc);

        if (error) {
            completionBlock(error, nil);
            return;
        }

        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            completionBlock(nil, image);
            return;
        }
    }];

    [task resume];
}

- (void)fetchManifest:(void (^)(NSError * _Nullable))completionBlock {

    NSURL *baseURL = [[NSURL URLWithString:baseURLString] URLByAppendingPathComponent:@"manifests/curiosity"];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:NO];

    urlComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"api_key" value:apiKey]
    ];


    NSURL *requestURL = urlComponents.URL;

    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:requestURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Inside of fetchManifest method with url: %@", requestURL);

        if (error) {
            completionBlock(error);
            return;
        }

        if (!data) {
            completionBlock(errorWithMessage(@"Error receiving data from manifest fetch request", 1));
            return;
        }

        NSError *jsonError = nil;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            completionBlock(jsonError);
            return;
        }

        NSDictionary *manifestDict = json[@"photo_manifest"];
        NSArray *photos = manifestDict[@"photos"];

        for (NSDictionary *photoDict in photos) {
            NSNumber *nsSolID = photoDict[@"sol"];
            if([nsSolID isKindOfClass:[NSNull class]]) { nsSolID = nil; }

            NSNumber *nsPhotoCount = photoDict[@"total_photos"];
            if([nsPhotoCount isKindOfClass:[NSNull class]]) { nsPhotoCount = nil; }

            NSArray<NSString *> *camerasDict = photoDict[@"cameras"];
            if([camerasDict isKindOfClass:[NSNull class]]) { camerasDict = nil; }

            // Check that all extracted properties and arrays are not nil. Check that the coun of the extracted array matches the count of the array
            if (nsSolID && nsPhotoCount && camerasDict) {
                WHLManifest *newManifest = [[WHLManifest alloc] initWithSolID:nsSolID.intValue photoCount:nsPhotoCount.intValue cameras:camerasDict];

                [self.manifests addObject:newManifest];
            }
#warning program won't alert when the nil checker and will move on to the next object in the array
            // TODO:- Add else statement to handle an attribute being nil
        }

        completionBlock(nil);

    }];

    [task resume];
}

- (void)fetchSolByManifest:(WHLManifest *)manifest completionBlock:(void (^)(NSError * _Nullable))completionBlock {

    NSURL *baseURL = [[NSURL URLWithString:baseURLString] URLByAppendingPathComponent:@"rovers/curiosity/photos"];

    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:baseURL resolvingAgainstBaseURL:NO];

    urlComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"sol" value:[NSString stringWithFormat:@"%d", manifest.solID]],
        [NSURLQueryItem queryItemWithName:@"api_key" value:apiKey]
    ];

    NSURL *requestURL = urlComponents.URL;

    NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithURL:requestURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Inside of fetchManifest method with url: %@", requestURL);

        if (error) {
            completionBlock(error);
            return;
        }

        if (!data) {
            completionBlock(errorWithMessage(@"Error receiving data from sol fetch request", 1));
            return;
        }

        NSError *jsonError = nil;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            completionBlock(jsonError);
            return;
        }

        NSArray *photosArray = json[@"photos"];

        for (NSDictionary *photoDict in photosArray) {
            NSNumber *sol = photoDict[@"sol"];
            if([sol isKindOfClass:[NSNull class]]) { sol = nil; }

            NSDictionary *camera = photoDict[@"camera"];
            NSString *cameraName = camera[@"name"];
            if([cameraName isKindOfClass:[NSNull class]]) { cameraName = nil; }

            NSString *cameraFullName = camera[@"full_name"];
            if([cameraFullName isKindOfClass:[NSNull class]]) { cameraFullName = nil; }

            NSDate *photoDate = [self.dateFormatter dateFromString:photoDict[@"earth_date"]];
            if([photoDate isKindOfClass:[NSNull class]]) { photoDate = nil; }

            NSURL *imgSrc = [NSURL URLWithString:photoDict[@"img_src"]];
            if([imgSrc isKindOfClass:[NSNull class]]) { imgSrc = nil; }

            NSDictionary *rover = photoDict[@"rover"];
            NSNumber *roverID = rover[@"id"];
            if([roverID isKindOfClass:[NSNull class]]) { roverID = nil; }

            NSString *roverName = rover[@"name"];
            if([roverName isKindOfClass:[NSNull class]]) { roverName = nil; }

            if (sol && cameraName && cameraFullName && photoDate && imgSrc && roverID && roverName) {
//                Photo *newPhoto = [[Photo alloc] init];
            }
#warning program won't alert when the nil checker and will move on to the next object in the array
            // TODO:- Add else statement to handle an attribute being nil
        }

        completionBlock(nil);

    }];

    [task resume];


}
@end

//
//  VRSVideo.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/3/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import "VRSVideo.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VRSVideo ()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) double duration;

@end

@implementation VRSVideo

- (instancetype)initWithFileURL:(NSURL *)aFileURL {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _fileURL = aFileURL;
    AVURLAsset *assetOfRecord = [AVURLAsset assetWithURL:aFileURL];
    CMTime duration = assetOfRecord.duration;
    _duration = CMTimeGetSeconds(duration);
    
    return self;
}

@end

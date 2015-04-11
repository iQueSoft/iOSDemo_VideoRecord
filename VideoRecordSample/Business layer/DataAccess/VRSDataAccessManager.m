//
//  VRSDataAccessManager.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/2/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import "VRSDataAccessManager.h"

// Frameworks
#import <UIKit/UIKit.h>

// Managers
#import "VRSFileManager.h"
#import "VRSVideoProcessor.h"

// Models
#import "VRSVideo.h"

@interface VRSDataAccessManager ()

@property (nonatomic, strong) NSMutableArray *videos;

@property (nonatomic, strong) NSMutableArray *cachedVideos;
@property (nonatomic, strong) VRSVideo *currentVideo;
@property (nonatomic, copy)   VRSDataAccessManagerCompletionBlock saveVideoCompletionBlock;
@property (nonatomic, strong) NSURL *currentVideoURL;

@property (nonatomic, assign) double totalDuration;

@end

@implementation VRSDataAccessManager

+ (instancetype)sharedDataAccessManager {
    static VRSDataAccessManager *_sharedDataAccessManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataAccessManager = [VRSDataAccessManager new];
    });
    
    return _sharedDataAccessManager;
}

- (void)addVideoURL:(NSURL *)aVideoURL {
    if (aVideoURL == nil) {
        return;
    }
    VRSVideo *newVideo = [[VRSVideo alloc] initWithFileURL:aVideoURL];
    self.totalDuration += newVideo.duration;
    [self.videos addObject:newVideo];
}

- (void)undo {
    VRSVideo *video = [self.videos lastObject];
    if (video) {
        [self.cachedVideos addObject:video];
        self.totalDuration -= video.duration;
        [self.videos removeLastObject];
    }
}

- (void)redo {
    VRSVideo *video = [self.cachedVideos lastObject];
    if (video) {
        [self.videos addObject:video];
        self.totalDuration += video.duration;
        [self.cachedVideos removeLastObject];
    }
}

- (void)clearCache {
    [self.cachedVideos removeAllObjects];
}

- (void)saveCurrentVideoWithCompletion:(VRSDataAccessManagerCompletionBlock)aCompletionBlock {
    
    self.saveVideoCompletionBlock = aCompletionBlock;
    
    VRSVideoProcessor *videoProcessor = [VRSVideoProcessor new];
    
    __block NSURL *outputURL = [VRSFileManager urlForVideo];
    
    RemoveFile(self.currentVideoURL);
    self.currentVideoURL = outputURL;
    
    __weak __typeof(self)weakSelf = self;
    
    [videoProcessor concateVideos:self.videos outputURL:outputURL completion:^(BOOL isCompletion) {
        if (isCompletion == NO) {
            weakSelf.saveVideoCompletionBlock = nil;
            aCompletionBlock(NO, nil);
            return;
        }
        UISaveVideoAtPathToSavedPhotosAlbum([outputURL path],
                                            self,
                                            @selector(video:didFinishSavingWithError:contextInfo:),
                                            nil);
    }];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    BOOL isDone = (error == nil);
    self.saveVideoCompletionBlock(isDone, error);
}

- (void)previewCurrentVideoWithCompletion:(VRSDataAccessManagerURLCompletionBlock)aCompletionBlock {
    
    VRSVideoProcessor *videoProcessor = [VRSVideoProcessor new];
    
    __block NSURL *outputURL = [VRSFileManager urlForVideo];
    
    RemoveFile(self.currentVideoURL);
    self.currentVideoURL = outputURL;
    
    [videoProcessor concateVideos:self.videos outputURL:outputURL completion:^(BOOL isCompletion) {
        aCompletionBlock(isCompletion, nil, outputURL);
    }];
}

#pragma mark -
#pragma mark Lazy load

- (NSMutableArray *)videos {
    if (_videos == nil) {
        _videos = [NSMutableArray array];
    }
    return _videos;
}

- (NSMutableArray *)cachedVideos {
    if (_cachedVideos == nil) {
        _cachedVideos = [NSMutableArray array];
    }
    return _cachedVideos;
}

@end

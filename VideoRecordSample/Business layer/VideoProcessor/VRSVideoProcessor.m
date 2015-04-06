//
//  VRSVideoProcessor.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/3/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import "VRSVideoProcessor.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Models
#import "VRSVideo.h"

// Managers
#import "VRSFileManager.h"

@interface VRSVideoProcessor ()

@property (nonatomic, strong) NSMutableSet *assests;
@property (nonatomic, strong) NSMutableSet *sessions;

@end

@implementation VRSVideoProcessor

- (void)concateVideos:(NSMutableArray *)anVideos
            outputURL:(NSURL *)anOutputURL
           completion:(void(^)(BOOL isCompletion))aCompletionBlock {
    
    if (![anVideos count]) {
        aCompletionBlock(NO);
        return;
    }
    
    __block NSMutableArray *audioTracks = [NSMutableArray new];
    __block NSMutableArray *videoTracks = [NSMutableArray new];
    
    NSMutableArray *assests = [NSMutableArray array];
    
    for (int index = ((int)[anVideos count] - 1); index >= 0; index--) {
        NSURL *url = ((VRSVideo *)anVideos[index]).fileURL;
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url
                                                options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
        
        if (asset) {
            [assests addObject:asset];
        }
        
        [videoTracks addObjectsFromArray:[asset tracksWithMediaType:AVMediaTypeVideo]];
        [audioTracks addObjectsFromArray:[asset tracksWithMediaType:AVMediaTypeAudio]];
    }
    
    if (![videoTracks count]) {
        aCompletionBlock(NO);
        return;
    }
    
    [self.assests addObjectsFromArray:assests];
    
    AVMutableComposition *composition = [AVMutableComposition new];
    
    if ([audioTracks count] > 0) {
        AVMutableCompositionTrack *audioTrackComposition = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];

        for (int index = 0; index < ((int)[audioTracks count]); index++) {
            AVAssetTrack *audioTrack = audioTracks[index];
            
            CMTime duration;
            CMTime audioDuration = audioTrack.timeRange.duration;
            
            duration = audioDuration;
            
            if ([videoTracks count] > index) {
                AVAssetTrack *videoTrack = videoTracks[index];
                CMTime videoDuration = videoTrack.timeRange.duration;
                
                if (CMTimeCompare(audioDuration, videoDuration) == 1) {
                    duration = videoDuration;
                }
            }
            
            [audioTrackComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                           ofTrack:audioTrack
                                            atTime:kCMTimeZero
                                             error:nil];
        }
    }
    
    AVMutableCompositionTrack *videoTrackComposition = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoTracks enumerateObjectsUsingBlock:^(AVAssetTrack *track, NSUInteger index, BOOL *stop) {
        AVAssetTrack *videoTrack = videoTracks[index];
        CMTime duration;
        CMTime videoDuration = videoTrack.timeRange.duration;
        
        duration = videoDuration;
        
        if ([audioTracks count] > index) {
            AVAssetTrack *audioTrack = audioTracks[index];
            CMTime audioDuration = audioTrack.timeRange.duration;
            
            if (CMTimeCompare(videoDuration, audioDuration) == 1) {
                duration = audioDuration;
            }
        }
        
        [videoTrackComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration)
                                       ofTrack:videoTrack
                                        atTime:kCMTimeZero
                                         error:nil];
    }];
    
    NSURL *outputURL = anOutputURL;

    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition
                                                                           presetName:AVAssetExportPreset1280x720];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = outputURL;
    
    [self.sessions addObject:exportSession];
    __weak typeof(self) weakSelf = self;
    
    DDLogDebug(@"Video processing: start concate videos");
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^ {
        switch (exportSession.status) {
            case AVAssetExportSessionStatusFailed: {
                
                DDLogError(@"Video processing: export session status failed");
                
                RemoveFile(outputURL);
                aCompletionBlock(NO);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                
                DDLogDebug(@"Video processing: success");
                
                aCompletionBlock(YES);
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                
                DDLogError(@"Video processing: export session status cancelled");
                
                RemoveFile(outputURL);
                aCompletionBlock(NO);
                break;
            }
            default: {
                break;
            }
        }
        
        [weakSelf.sessions removeObject:exportSession];
        [assests enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
            [weakSelf.assests removeObject:asset];
        }];
    }];
}

#pragma mark -
#pragma mark Lazy load

- (NSMutableSet *)sessions {
    if (_sessions == nil) {
        _sessions = [NSMutableSet set];
    }
    return _sessions;
}

- (NSMutableSet *)assests {
    if (_assests == nil) {
        _assests = [NSMutableSet set];
    }
    return _assests;
}

@end

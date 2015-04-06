//
//  VRSFileManager.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/2/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import "VRSFileManager.h"

@interface VRSFileManager ()

@end

@implementation VRSFileManager

#pragma mark -
#pragma mark Videos

+ (NSURL *)urlForVideo {
    if ([self checkVideosDirectory] == NO) {
        return nil;
    }
    NSURL *urlForFragment = nil;
    long long timeInterval = (long long)(((double)[[NSDate date] timeIntervalSince1970]) * 1000);
    urlForFragment = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@Videos/video-%lld%@",
                                             NSTemporaryDirectory(),
                                             timeInterval,
                                             @".MOV"]];
    return urlForFragment;
}

+ (BOOL)clearVideosDirectory {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"/Videos/"]
                                         isDirectory:&isDirectory];
    if (isDirectory == NO) {
        return YES;
    }
    BOOL videosIsRemove = [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"/Videos/"]
                                                                     error:nil];
    return videosIsRemove;
}

#pragma mark -
#pragma mark @private

+ (BOOL)checkVideosDirectory {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"/Videos/"]
                                         isDirectory:&isDirectory];
    if (isDirectory) {
        return YES;
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"/Videos"]
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
}

@end

#pragma mark -
#pragma mark Functions

NSError* RemoveFile(NSURL *fileURL) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    NSError *error;
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:&error];
    }
    return error;
}

BOOL CheckFileExists(NSURL *fileURL) {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        return NO;
    }
    return YES;
}

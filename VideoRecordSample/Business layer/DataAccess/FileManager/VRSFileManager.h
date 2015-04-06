//
//  VRSFileManager.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/2/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRSFileManager : NSObject

#pragma mark -
#pragma mark Video

+ (NSURL *)urlForVideo;

+ (BOOL)clearVideosDirectory;

@end

#pragma mark -
#pragma mark Functions

NSError * RemoveFile(NSURL *fileURL);

BOOL CheckFileExists(NSURL *fileURL);

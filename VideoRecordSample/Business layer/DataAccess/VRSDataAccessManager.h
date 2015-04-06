//
//  VRSDataAccessManager.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/2/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VRSVideo;
@class UIViewController;

typedef void (^VRSDataAccessManagerCompletionBlock)(BOOL isDone, NSError *anError);
typedef void (^VRSDataAccessManagerURLCompletionBlock)(BOOL isDone, NSError *anError, NSURL *aContentURL);

@interface VRSDataAccessManager : NSObject

@property (nonatomic, readonly) double totalDuration;

+ (instancetype)sharedDataAccessManager;

- (void)addVideoURL:(NSURL *)aVideoURL;

- (void)undo;

- (void)redo;

- (void)clearCache;

- (void)saveCurrentVideoWithCompletion:(VRSDataAccessManagerCompletionBlock)aCompletionBlock;

- (void)previewCurrentVideoWithCompletion:(VRSDataAccessManagerURLCompletionBlock)aCompletionBlock;

@end

//
//  VRSVideoProcessor.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/3/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRSVideoProcessor : NSObject

- (void)concateVideos:(NSMutableArray *)anVideos
            outputURL:(NSURL *)anOutputURL
           completion:(void(^)(BOOL isCompletion))aCompletionBlock;

@end

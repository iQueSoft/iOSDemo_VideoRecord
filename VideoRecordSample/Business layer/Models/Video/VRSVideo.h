//
//  VRSVideo.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/3/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRSVideo : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) double duration;

- (instancetype)initWithFileURL:(NSURL *)aFileURL;

@end

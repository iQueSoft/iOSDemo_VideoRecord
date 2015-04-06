//
//  VRSVideoWritter.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocols
#import "VRSVideoWritterProtocol.h"

// Frameworks
#import <UIKit/UIKit.h>

extern NSString *const kRecordingNotificationString;
extern NSString *const kAutostopNotificationString;
extern NSString *const kRecordingProgressKey;

@interface VRSVideoWritter : NSObject <VRSVideoWritterProtocol>

@property (nonatomic, readonly) BOOL recording;
@property (nonatomic, assign) double maxDuration;

@property (nonatomic, assign) UIInterfaceOrientation videoOrientation;

@end

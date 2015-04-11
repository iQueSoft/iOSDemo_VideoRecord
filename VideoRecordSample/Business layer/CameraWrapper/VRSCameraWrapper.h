//
//  VRSCameraWrapper.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import <Foundation/Foundation.h>

// Frameworks
#import <UIKit/UIKit.h>

// Protocols
#import "VRSVideoWritterProtocol.h"

@interface VRSCameraWrapper : NSObject

@property (nonatomic, weak) UIView *previewView;
@property (nonatomic, assign) UIInterfaceOrientation videoOrientation;

- (instancetype)initWithPreviewView:(UIView *)aPreviewView;

- (void)setupCamera;

- (void)flipCamera;

- (void)addVideoWritter:(id<VRSVideoWritterProtocol>)aVideoWritter;

- (void)removeVideoWritter:(id<VRSVideoWritterProtocol>)aVideoWritter;

@end

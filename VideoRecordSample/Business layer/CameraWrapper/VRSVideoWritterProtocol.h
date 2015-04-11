//
//  VRSVideoWritterProtocol.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/2/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

@class AVCaptureSession;

@protocol VRSVideoWritterProtocol <NSObject>

@required

- (void)addCaptureSession:(AVCaptureSession *)aCaptureSession;

- (void)removeCaptureSession:(AVCaptureSession *)aCaptureSession;

- (void)startRecording;

- (void)stopRecording;

@end

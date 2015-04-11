//
//  VRSVideoWritter.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import "VRSVideoWritter.h"

// Frameworks
#import <AVFoundation/AVFoundation.h>

// Managers
#import "VRSFileManager.h"
#import "VRSDataAccessManager.h"

NSString *const kRecordingNotificationString = @"kRecordingNotificationString";
NSString *const kAutostopNotificationString = @"kAutostopNotificationString";
NSString *const kRecordingProgressKey = @"kRecordingProgressKey";

@interface VRSVideoWritter () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, assign) BOOL recording;

@end

@implementation VRSVideoWritter

#pragma mark -
#pragma mark VRSVideoWritterProtocol

- (void)addCaptureSession:(AVCaptureSession *)aCaptureSession {
    
    self.captureSession = aCaptureSession;

    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    self.videoOrientation = UIInterfaceOrientationLandscapeRight;

    [self.captureSession commitConfiguration];
}

- (void)removeCaptureSession:(AVCaptureSession *)aCaptureSession {
    [self.captureSession beginConfiguration];
    [aCaptureSession removeOutput:self.movieFileOutput];
    [self.captureSession commitConfiguration];
}

- (void)startRecording {
    
    DDLogDebug(@"Start recording");
    
    self.recording = YES;
    
    NSURL *outputURL = [VRSFileManager urlForVideo];

    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
    
    self.progressTimer = [NSTimer timerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(timerDidFire:)
                                               userInfo:nil
                                                repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer
                              forMode:NSDefaultRunLoopMode];
}

- (void)stopRecording {
    
    DDLogDebug(@"Stop recording");
    
    self.recording = NO;
	
    if (self.progressTimer != nil) {
        if ([self.progressTimer isValid]) {
            [self.progressTimer invalidate];
        }
        self.progressTimer = nil;
    }
    
    [self.movieFileOutput stopRecording];
}

- (void)timerDidFire:(NSTimer *)timer {
    double progress = CMTimeGetSeconds(self.movieFileOutput.recordedDuration);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecordingNotificationString
                                                        object:self
                                                      userInfo:@{kRecordingProgressKey: @(progress)}];
    
    if (progress >= self.maxDuration) {
        [self stopRecording];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAutostopNotificationString
                                                            object:self
                                                          userInfo:nil];
    }
}

#pragma mark -
#pragma mark Setters

- (void)setVideoOrientation:(UIInterfaceOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    
    AVCaptureConnection *CaptureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if ([CaptureConnection isVideoOrientationSupported]) {
        [CaptureConnection setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation];
    }
}

#pragma mark -
#pragma mark AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    DDLogDebug(@"Finish recording");
    
    [[VRSDataAccessManager sharedDataAccessManager] addVideoURL:outputFileURL];
    
}

@end

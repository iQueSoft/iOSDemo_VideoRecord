//
//  VRSCameraWrapper.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 Work. All rights reserved.
//

#import "VRSCameraWrapper.h"

// Frameworks
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface VRSCameraWrapper ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation VRSCameraWrapper

- (instancetype)initWithPreviewView:(UIView *)aPreviewView {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.previewView = aPreviewView;
    
    return self;
}

- (void)addVideoWritter:(id<VRSVideoWritterProtocol>)aVideoWritter {
    [aVideoWritter addCaptureSession:self.captureSession];
}

- (void)removeVideoWritter:(id<VRSVideoWritterProtocol>)aVideoWritter {
    [aVideoWritter removeCaptureSession:self.captureSession];
}

- (void)setupCamera {

    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (videoDevice) {
        NSError *error;
        self.videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (!error) {
            if ([self.captureSession canAddInput:self.videoInputDevice]) {
                [self.captureSession addInput:self.videoInputDevice];
            } else {
                DDLogError(@"Couldn't add video input");
            }
        } else {
            DDLogError(@"Couldn't create video input");
        }
    } else {
        DDLogError(@"Couldn't create video capture device");
    }
    
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput) {
        [self.captureSession addInput:audioInput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    AVCaptureConnection *previewLayerConnection = self.previewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported]) {
        [previewLayerConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    
    CGRect layerRect = [[[self previewView] layer] bounds];
    [self.previewLayer setBounds:layerRect];
    [self.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    UIView *CameraView = [[UIView alloc] init];
    [[self previewView] addSubview:CameraView];
    [[self previewView] sendSubviewToBack:CameraView];
    
    [[CameraView layer] addSublayer:self.previewLayer];
    
    [self.captureSession startRunning];
}

- (void)flipCamera {
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[self.videoInputDevice device] position];
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
        }
        
        if (newVideoInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.videoInputDevice];
            if ([self.captureSession canAddInput:newVideoInput]) {
                [self.captureSession addInput:newVideoInput];
                self.videoInputDevice = newVideoInput;
            } else {
                [self.captureSession addInput:self.videoInputDevice];
            }
            
            [self.captureSession commitConfiguration];
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Setters

- (void)setVideoOrientation:(UIInterfaceOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    
    AVCaptureConnection *previewLayerConnection = self.previewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported]) {
        [previewLayerConnection setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation];
    }
}

@end

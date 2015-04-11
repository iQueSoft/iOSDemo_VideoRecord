//
//  VRSRecordViewController.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import "VRSRecordViewController.h"

// Camera
#import "VRSCameraWrapper.h"

// Writter
#import "VRSVideoWritter.h"

// UI
#import "VRSBlinkView.h"
#import "MBProgressHUD.h"

// Data source
#import "VRSDataAccessManager.h"

// Helpers
#import "DurationStringFromTimeInterval.h"

// Strings
#define kErrorString NSLocalizedString(@"Error!", nil)
#define kProcessingVideoString NSLocalizedString(@"Video processing...", nil)
#define kSaveCompleteString NSLocalizedString(@"Save complete!", nil)
#define kRecordVideoFirstString NSLocalizedString(@"You should record a video first.", nil)

static const double maxDuration = 5.0 * 60.0f;

@interface VRSRecordViewController ()

@property (nonatomic, strong) VRSCameraWrapper *cameraWrapper;
@property (nonatomic, strong) VRSVideoWritter *videoWritter;

@property (weak, nonatomic) IBOutlet VRSBlinkView *blinkView;
@property (weak, nonatomic) IBOutlet UIButton *flipCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxDurationLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *recordingProgressView;

@end

@implementation VRSRecordViewController

#pragma mark -
#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraWrapper = [[VRSCameraWrapper alloc] initWithPreviewView:self.view];
    [self.cameraWrapper setupCamera];
    
    self.videoWritter = [VRSVideoWritter new];
    [self.cameraWrapper addVideoWritter:self.videoWritter];
    
    [UIView setAnimationsEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRecordingProgress:)
                                                 name:kRecordingNotificationString
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autostopRecording:)
                                                 name:kAutostopNotificationString
                                               object:nil];
    
    self.videoWritter.maxDuration = maxDuration;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Notifications

- (void)updateRecordingProgress:(NSNotification *)aNotification {
    NSDictionary *userInfo = aNotification.userInfo;
    double progress = [userInfo[kRecordingProgressKey] doubleValue];
    [self updateRecordingProgressUI:progress];
}

- (void)autostopRecording:(NSNotification *)aNotification {
    [self stopRecording];
}

#pragma mark -
#pragma mark Recording

- (void)startRecording {
    [[VRSDataAccessManager sharedDataAccessManager] clearCache];
    self.videoWritter.maxDuration = maxDuration - [VRSDataAccessManager sharedDataAccessManager].totalDuration;
    [self lockUI];
    [self.blinkView startBlinkAnimation];
    [self.videoWritter startRecording];
}

- (void)stopRecording {
    [self unlockUI];
    [self.blinkView stopBlinkAnimation];
    [self.videoWritter stopRecording];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)startRecordAction:(id)sender {
    [self startRecording];
}

- (IBAction)stopRecordAction:(id)sender {
    [self stopRecording];
}

- (IBAction)flipCameraAction:(id)sender {
    [self.cameraWrapper flipCamera];
}

- (IBAction)previewAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = kProcessingVideoString;
    [[VRSDataAccessManager sharedDataAccessManager] previewCurrentVideoWithCompletion:^(BOOL isDone, NSError *anError, NSURL *aContentURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (isDone == NO) {
                [self showAlertOKWithTitle:kErrorString message:kRecordVideoFirstString];
            } else {
                [self previewVideoByURL:aContentURL];
            }
        });
    }];
}

- (IBAction)saveAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = kProcessingVideoString;
    [[VRSDataAccessManager sharedDataAccessManager] saveCurrentVideoWithCompletion:^(BOOL isDone, NSError *anError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (isDone == NO) {
                [self showAlertOKWithTitle:kErrorString message:kRecordVideoFirstString];
            } else {
                [self showAlertOKWithText:kSaveCompleteString];
            }
        });
    }];
}

- (IBAction)undoAction:(id)sender {
    [[VRSDataAccessManager sharedDataAccessManager] undo];
    [self updateRecordingProgressUI:0];
}

- (IBAction)redoAction:(id)sender {
    [[VRSDataAccessManager sharedDataAccessManager] redo];
    [self updateRecordingProgressUI:0];
}

#pragma mark -
#pragma mark UIViewControllerRotation

- (BOOL)shouldAutorotate {    
    if (self.videoWritter.recording == YES) {
        return NO;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    self.cameraWrapper.videoOrientation = orientation;
    self.videoWritter.videoOrientation = orientation;
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -
#pragma mark Lock UI

- (void)lockUI {
    self.flipCameraButton.hidden = YES;
    self.saveButton.hidden = YES;
    self.previewButton.hidden = YES;
    self.undoButton.hidden = YES;
    self.redoButton.hidden = YES;
}

- (void)unlockUI {
    self.flipCameraButton.hidden = NO;
    self.saveButton.hidden = NO;
    self.previewButton.hidden = NO;
    self.undoButton.hidden = NO;
    self.redoButton.hidden = NO;
}

#pragma mark -
#pragma mark Update progress

- (void)updateRecordingProgressUI:(double)progress {
    double totalProgress = [VRSDataAccessManager sharedDataAccessManager].totalDuration;
    totalProgress += progress;
    self.progressLabel.text = DurationFromTimeInterval(totalProgress);
    
    totalProgress = 1 / maxDuration * totalProgress;
    
    if (totalProgress < 1 / maxDuration) {
        totalProgress = 0.0;
    }
    
    [self.recordingProgressView setProgress:totalProgress animated:YES];
}

@end

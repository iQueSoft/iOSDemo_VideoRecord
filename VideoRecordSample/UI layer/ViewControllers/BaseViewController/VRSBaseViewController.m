//
//  VRSBaseViewController.m
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import "VRSBaseViewController.h"

// Frameworks
#import <MediaPlayer/MediaPlayer.h>

// Strings
#define kOKString NSLocalizedString(@"OK", nil)

@interface VRSBaseViewController ()

@end

@implementation VRSBaseViewController

#pragma mark -
#pragma mark Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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

#pragma mark -
#pragma mark @publick

- (void)previewVideoByURL:(NSURL *)aVideoURL {
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:aVideoURL];
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer play];
}

- (void)showAlertOKWithText:(NSString *)aTextString {
    [self showAlertOKWithTitle:aTextString message:nil];
}

- (void)showAlertOKWithTitle:(NSString *)aTitleString message:(NSString *)aMessageString {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:aTitleString message:aMessageString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kOKString style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

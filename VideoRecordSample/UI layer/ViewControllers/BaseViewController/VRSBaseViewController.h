//
//  VRSBaseViewController.h
//  VideoRecordSample
//
//  Created by Ruslan Shevtsov on 4/1/15.
//  Copyright (c) 2015 iQueSoft rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRSBaseViewController : UIViewController

- (void)previewVideoByURL:(NSURL *)aVideoURL;

- (void)showAlertOKWithText:(NSString *)aTextString;

- (void)showAlertOKWithTitle:(NSString *)aTitleString message:(NSString *)aMessageString;

@end

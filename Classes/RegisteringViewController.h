//
//  RegisteringViewController.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/10/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegisteringViewController;

@interface RegisteringViewController : UIViewController {
	UIButton *buttonCancel;
	UIActivityIndicatorView *activityIndicatorView;
}

@property (retain, nonatomic) IBOutlet UIButton *buttonCancel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction) onbuttonCancelClick: (id)sender;

@end

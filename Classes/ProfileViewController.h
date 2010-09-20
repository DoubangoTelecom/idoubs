//
//  ProfileViewController.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/11/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileViewController : UIViewController {

	IBOutlet UIButton *buttonSignInOut;
	IBOutlet UILabel *labelDebug;
}

@property (retain, nonatomic) IBOutlet UIButton *buttonSignInOut;
@property (retain, nonatomic) IBOutlet UILabel *labelDebug;

- (IBAction) onbuttonSignInOutClick: (id)sender;

@end

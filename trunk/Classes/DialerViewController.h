//
//  DialerViewController.h
//  iDoubs
//
//  Created by Mamadou DIOP on 9/3/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DialerViewControllerDelegate
	-(void)setAddress:(NSString*)address;
@end

@interface DialerViewController : UIViewController<DialerViewControllerDelegate, UITextFieldDelegate> {
	IBOutlet UIButton *buttonZero;
	IBOutlet UIButton *buttonOne;
	IBOutlet UIButton *buttonTwo;
	IBOutlet UIButton *buttonThree;
	IBOutlet UIButton *buttonFour;
	IBOutlet UIButton *buttonFive;
	IBOutlet UIButton *buttonSix;
	IBOutlet UIButton *buttonSeven;
	IBOutlet UIButton *buttonEight;
	IBOutlet UIButton *buttonNine;
	IBOutlet UIButton *buttonStar;
	IBOutlet UIButton *buttonSharp;
	
	IBOutlet UITextField *textFieldAddress;
	IBOutlet UIButton *buttonPickContact;
	
	IBOutlet UIButton *buttonVoice;
	IBOutlet UIButton *buttonDel;
	IBOutlet UIButton *buttonVideo;
}

@property (retain, nonatomic) IBOutlet UIButton *buttonZero;
@property (retain, nonatomic) IBOutlet UIButton *buttonOne;
@property (retain, nonatomic) IBOutlet UIButton *buttonTwo;
@property (retain, nonatomic) IBOutlet UIButton *buttonThree;
@property (retain, nonatomic) IBOutlet UIButton *buttonFour;
@property (retain, nonatomic) IBOutlet UIButton *buttonFive;
@property (retain, nonatomic) IBOutlet UIButton *buttonSix;
@property (retain, nonatomic) IBOutlet UIButton *buttonSeven;
@property (retain, nonatomic) IBOutlet UIButton *buttonEight;
@property (retain, nonatomic) IBOutlet UIButton *buttonNine;
@property (retain, nonatomic) IBOutlet UIButton *buttonStar;
@property (retain, nonatomic) IBOutlet UIButton *buttonSharp;


@property (retain, nonatomic) IBOutlet UITextField *textFieldAddress;
@property (retain, nonatomic) IBOutlet UIButton *buttonPickContact;

@property (retain, nonatomic) IBOutlet UIButton *buttonVoice;
@property (retain, nonatomic) IBOutlet UIButton *buttonDel;
@property (retain, nonatomic) IBOutlet UIButton *buttonVideo;

- (IBAction) onKeyboardClick: (id)sender;
- (IBAction) onPickContactClick: (id)sender;
- (IBAction) onAVCallClick: (id)sender;
- (IBAction) onDelClick: (id)sender;

@end

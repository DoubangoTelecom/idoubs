/*
 * Copyright (C) 2010 Mamadou Diop.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango.org>
 *       
 * This file is part of idoubs Project (http://code.google.com/p/idoubs)
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

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

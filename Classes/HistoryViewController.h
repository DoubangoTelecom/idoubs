//
//  HistoryViewController.h
//  iDoubs
//
//  Created by Mamadou DIOP on 8/27/10.
//  Copyright 2010 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DialerViewController.h"

@interface HistoryViewController : UITableViewController {
	NSDateFormatter* dateFormatterDuration;
	NSDateFormatter* dateFormatterDate;
	
	NSObject<DialerViewControllerDelegate> *delegateDialer;
}

@property (retain, nonatomic) NSObject<DialerViewControllerDelegate> *delegateDialer;

@end

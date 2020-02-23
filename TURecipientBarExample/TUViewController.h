//
//  TUViewController.h
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

@import UIKit;
#import <TURecipientBar/TURecipientBar.h>

@class TUABSearchSource;


@interface TUViewController : UIViewController <TURecipientsDisplayDelegate, TURecipientsBarDelegate>

@property (nonatomic, strong) IBOutlet TURecipientsDisplayController *recipientDisplayController;
@property (weak, nonatomic) IBOutlet TURecipientsBar *recipientsBar;
@property (nonatomic, strong) IBOutlet TUABSearchSource *searchSource;

@end

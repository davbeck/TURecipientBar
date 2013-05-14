//
//  TUViewController.h
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TURecipientDisplayController.h"

@class TUABSearchSource;


@interface TUViewController : UIViewController <TUComposeDisplayDelegate, TUComposeBarDelegate>

@property (nonatomic, strong) IBOutlet TURecipientDisplayController *recipientDisplayController;
@property (weak, nonatomic) IBOutlet TURecipientBar *composeBar;
@property (nonatomic, strong) IBOutlet TUABSearchSource *searchSource;

@end

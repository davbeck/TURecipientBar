//
//  TUViewController.m
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import "TUViewController.h"

#import "Example-Swift.h"
#import "TUABSearchSource.h"


@interface TUViewController ()

@end

@implementation TUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.recipientsBar.usesTransparency = YES;
    
    // we don't want our initial state to animate in
    self.recipientsBar.animatedRecipientsInAndOut = NO;
    
//    self.recipientsBar.showsAddButton = NO;
//    self.recipientsBar.placeholder = NSLocalizedString(@"Type names...", nil);
//    self.recipientsBar.label = @"Send To: ";
//    self.recipientsBar.label = @"";
    
//    UIImage *backgroundImage = [[UIImage imageNamed:@"token"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];
//    [[TURecipientsBar appearance] setRecipientBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    NSDictionary *attributes = @{
//                                 NSFontAttributeName: [UIFont fontWithName:@"American Typewriter" size:14.0],
//                                 NSForegroundColorAttributeName: [UIColor yellowColor],
//                                 };
//    [[TURecipientsBar appearance] setRecipientTitleTextAttributes:attributes forState:UIControlStateNormal];
//    
//    NSDictionary *labelAttributes = @{
//                                      NSFontAttributeName: [UIFont fontWithName:@"Marker Felt" size:14.0],
//                                      NSForegroundColorAttributeName: [UIColor redColor],
//                                      };
//    [[TURecipientsBar appearance] setLabelTextAttributes:labelAttributes];
    
//    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"John Burke" address:nil]];
//    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"David Beck" address:nil]];
//    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"Frank Mann" address:nil]];
//    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"Tom Nelson" address:nil]];
    
    
    
    
    // Large scale testing:
//    for (NSUInteger i = 0; i < 50; i++) {
//        [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"John Burke" address:nil]];
//        [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"David Beck" address:nil]];
//        [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"Frank Mann" address:nil]];
//        [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"Tom Nelson" address:nil]];
//    }
    
    
    self.recipientsBar.animatedRecipientsInAndOut = YES;
}


#pragma mark - Actions

- (IBAction)addRecipient:(id)sender
{
    [self.recipientsBar addRecipient:[TURecipient recipientWithTitle:@"John Burke" address:nil]];
}

- (IBAction)changeExpandedMode:(UISwitch *)sender
{
	[UIView animateWithDuration:0.2 animations:^{
		self.recipientsBar.displayMode = sender.on ? TURecipientsBarDisplayModeExpanded : TURecipientsBarDisplayModeAutomatic;
	}];
}


#pragma mark - TSRecipientsDisplayDelegate

- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar
{
	if (recipientsBar.text.length == 0) {
		[recipientsBar resignFirstResponder];
	}
}

- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	self.searchSource.tableView = tableView;
}

- (BOOL)recipientsDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	self.searchSource.searchTerm = searchString;
	
	return YES;
}

/*
// Uncomment to disable the search table view.
// The shouldReloadTableForSearchString method and other text change methods will still be called, so you can provide your own search UI
- (BOOL)recipientsDisplayControllerShouldBeginSearch:(TURecipientsDisplayController *)controller
{
    return NO;
 }
 */

/*
// Uncomment to customize the recipient view.
- (nullable UIControl *)recipientsBar:(nonnull TURecipientsBar *)recipientsBar viewForRecipient:(nonnull id<TURecipient>)recipient
{
	ChipView *view = [[ChipView alloc] init];
	
	view.nameLabel.text = recipient.recipientTitle;
	
	[view.removeButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
	
	return view;
}
 */

- (void)remove {
	[self.recipientsBar removeRecipient:self.recipientsBar.recipients.lastObject];
}

@end

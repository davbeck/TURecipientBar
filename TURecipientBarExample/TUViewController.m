//
//  TUViewController.m
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import "TUViewController.h"

#import "TUABSearchSource.h"


@interface TUViewController ()

@end

@implementation TUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.recipientsBar.showsAddButton = NO;
//    self.recipientsBar.placeholder = NSLocalizedString(@"Type names...", nil);
//    self.recipientsBar.label = @"To:";
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
 Uncomment to disable the search table view.
 The shouldReloadTableForSearchString method and other text change methods will still be called, so you can provide your own search UI
- (BOOL)recipientsDisplayControllerShouldBeginSearch:(TURecipientDisplayController *)controller
{
    return NO;
}
 */

@end

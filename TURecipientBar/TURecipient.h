//
//  TURecipient.h
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>


/** A recipient object that will be represented with a token.
 
 Any object can be used as a recipient as long as it conforms to the NSCopying protocol.
 */
@protocol TURecipient <NSObject, NSCopying>

/**---------------------------------------------------------------------------------------
 * @name Title
 *  ---------------------------------------------------------------------------------------
 */

/** The title that will be displayed in the `TURecipientsBar`.
 
 You can create a category that returns a different property for this value.
 For instance, an `NSManagedObject` could return it's name property
 */
@property (nonatomic, readonly, copy) NSString *recipientTitle;

@end


/** A default and bare implimentation of the `<TURecipient>` protocol.
 
 You can use this to get going quickly with recipients, or to wrap other objects using the address property.
 
 `TURecipientsDisplayController` uses this class for default bare recipient creation.
 */


@interface TURecipient : NSObject <TURecipient>

/**---------------------------------------------------------------------------------------
 * @name Address
 *  ---------------------------------------------------------------------------------------
 */

/** Aliase for recipientTitle.
 
 This is for backwards compatability. Use `recipientTitle` instead.
 */
@property (nonatomic, readonly, copy) NSString *title __attribute__((deprecated));

/** A generic reference to a model.
 
 You can use this to keep track of what a recipient points to.
 */
@property (nonatomic, readonly, strong) id address;


/** Create a new recipient.
 
 Because this class is immutable, this is the only way to set the title and address properties.
 If you need to make a change, you should create a new one. This is because the recipients bar will not track changes.
 */
+ (id)recipientWithTitle:(NSString *)title address:(id)address;

@end

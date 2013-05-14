//
//  TURecipient.h
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TURecipient : NSObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, strong) id address;

+ (id)recipientWithTitle:(NSString *)title address:(id)address;

@end

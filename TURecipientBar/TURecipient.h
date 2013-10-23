//
//  TURecipient.h
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TURecipient <NSObject, NSCopying>

@property (nonatomic, readonly, copy) NSString *recipientTitle;

@end


@interface TURecipient : NSObject <TURecipient>

@property (nonatomic, readonly, copy) NSString *title __attribute__((deprecated));
@property (nonatomic, readonly, strong) id address;

+ (id)recipientWithTitle:(NSString *)title address:(id)address;

@end

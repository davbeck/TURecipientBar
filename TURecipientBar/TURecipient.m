//
//  TURecipient.m
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipient.h"

@interface TURecipient ()

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, strong) id address;

@end

@implementation TURecipient

+ (id)recipientWithTitle:(NSString *)title address:(id)address
{
	TURecipient *recipient = [[TURecipient alloc] init];
	
	recipient.title = title;
	recipient.address = address;
	
	return recipient;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: title=%@, address=%@>", NSStringFromClass([self class]), self.title, self.address];
}

@end

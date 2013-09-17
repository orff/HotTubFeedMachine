//
//  HTHelper.h
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/17/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTUtils : NSObject

+(void)alertBox:(NSString *)message;
+(void)addAutoLayoutConstraintsToView:(NSView *)subView withSuperView:(NSView *)superview;

@end

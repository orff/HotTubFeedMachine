//
//  Document.h
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/6/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MasterViewController;
@interface Document : NSDocument

@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;

@end

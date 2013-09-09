//
//  Document.h
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/6/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MasterViewController, RecordingSession;
@interface Document : NSDocument {
    RecordingSession *currentSession;
}

@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;

@end

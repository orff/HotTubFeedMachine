//
//  ScrubberControl.h
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/13/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ScrubberControlDelegate

@optional
-(void)scrubberDidUpdateAtPosition:(float)position;
@end

@interface ScrubberControl : NSControl {
    BOOL dragging;
    CGPoint lastDragLocation;
}

@property (nonatomic, weak) id <ScrubberControlDelegate> delegate;

@property (strong, nonatomic) NSBox *scrubberBox;

@end

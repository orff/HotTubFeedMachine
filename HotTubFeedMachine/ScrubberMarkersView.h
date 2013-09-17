//
//  ScrubberMarkersView.h
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/17/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrubberMarkersView : NSView {
    bool isDrawing;
}

@property (strong, nonatomic) NSMutableArray *tickMarkPercents;

-(void)drawTicks;

@end

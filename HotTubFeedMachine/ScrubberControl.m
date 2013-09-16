//
//  ScrubberControl.m
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/13/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "ScrubberControl.h"

@implementation ScrubberControl

-(CGRect)calculatedItemBounds {
    return self.bounds;
}

- (BOOL)isPointInItem:(NSPoint)testPoint
{
    BOOL itemHit=NO;
    
    // test first if we're in the rough bounds
    itemHit = NSPointInRect(testPoint,[self calculatedItemBounds]);
    
    // yes, lets further refine the testing
    if (itemHit) {
        // if this was a non-rectangular shape, you would refine
        // the hit testing here
    }
    
    return itemHit;
}


-(void)mouseExited:(NSEvent *)theEvent {
    //[NSCursor pop];
}
-(void)mouseUp:(NSEvent *)theEvent
{
    //[NSCursor pop];
}

-(void)mouseDragged:(NSEvent *)event {
    NSLog(@"mouse dragged on Scrubber control");
    NSPoint clickLocation;
    BOOL itemHit=NO;
    
    // convert the mouse-down location into the view coords
    clickLocation = [self convertPoint:[event locationInWindow]
                              fromView:nil];
    
    // did the mouse-down occur in the item?
    itemHit = [self isPointInItem:clickLocation];
    
    if (itemHit) {
        float position = clickLocation.x;
        [self.delegate scrubberDidUpdateAtPosition:(float)position];
    }
}

-(void)mouseDown:(NSEvent *)event
{
    NSLog(@"mouse Down on Scrubber control");
    NSPoint clickLocation;
    BOOL itemHit=NO;
    
    // convert the mouse-down location into the view coords
    clickLocation = [self convertPoint:[event locationInWindow]
                              fromView:nil];
    
    // did the mouse-down occur in the item?
    itemHit = [self isPointInItem:clickLocation];
    
    // Yes it did, note that we're starting to drag
    if (itemHit) {
        // flag the instance variable that indicates
        // a drag was actually started
        dragging=YES;
        
        // store the starting mouse-down location;
        lastDragLocation=clickLocation;
        
        // set the cursor to the closed hand cursor
        // for the duration of the drag
        //[[NSCursor pointingHandCursor] push];
        
        float position = clickLocation.x;
        [self.delegate scrubberDidUpdateAtPosition:position];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end

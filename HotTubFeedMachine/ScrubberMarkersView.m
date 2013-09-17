//
//  ScrubberMarkersView.m
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/17/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "ScrubberMarkersView.h"
#import "constants.h"

@implementation ScrubberMarkersView

int padding = 2; // how mch to pad the end of the display

-(void)updateTicks {
    if (isDrawing) return;
    
    int cnt=0;
    for (NSView *v in self.subviews) {
        float barPercent = [[self.tickMarkPercents objectAtIndex:cnt] floatValue];
        float currentBarXpos = (int)(barPercent * (self.frame.size.width-padding));
        v.frame = NSMakeRect(currentBarXpos, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
        
        cnt++;
    }
}

-(void)drawTicks {
    isDrawing = YES;
    if (self.subviews.count > 0) return; //dont redra if its not emptied out
    
    int cnt=0;
    for (NSNumber *n in self.tickMarkPercents) {
        float barPercent = [n floatValue];
        float currentBarXpos = (int)(barPercent * (self.frame.size.width-padding));
        
        NSBox *verticalLine = [[NSBox alloc] initWithFrame:NSMakeRect(currentBarXpos, 20, 1, 20)];
        verticalLine.identifier = [NSString stringWithFormat:@"line-%i", cnt];
        verticalLine.boxType = NSBoxSeparator;
        verticalLine.borderColor = [NSColor blackColor];
        [self addSubview:verticalLine];
        
        cnt++;
    }
    
    isDrawing = NO;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.tickMarkPercents = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"scrubberMarker drawRect");
    // Drawing code here.
    if (DEBUG_DRAW_CONTAINERS) {
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.5] setFill];
        NSRectFill(dirtyRect);
        [super drawRect:dirtyRect];
    }
    
    [self updateTicks];
}

@end

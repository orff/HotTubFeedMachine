//
//  MasterViewController.h
//  FeedSimulator
//
//  Created by Hill, Michael on 8/14/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MongooseDaemon.h"

typedef NS_ENUM(uint8_t, enumAppStatus) {
    sIdol,
    sRecording,
    sStopped,
    sPlaying,
};

@class RecordingSession;

@interface MasterViewController : NSViewController <NSTextFieldDelegate> {
    MongooseDaemon    *mongooseDaemon;
    
    NSTimer *recordingTimer;
    NSTimer *playbackTimer;
    
    bool isServerup;
    bool isFeedURLValid;
    
    enumAppStatus currentStatus;
    
    NSString *lastFeedResponse;
    NSDate *lastResposeTime;
    
    RecordingSession *currentSession;
}

@property (strong, nonatomic) IBOutlet NSTextField *statusTextField;

@property (strong, nonatomic) IBOutlet NSTextField *feedTextField;

@property (strong, nonatomic) IBOutlet NSButton *recordButton;

@property (strong, nonatomic) IBOutlet NSView *progressContainer;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

@end

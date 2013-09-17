//
//  MasterViewController.h
//  FeedSimulator
//
//  Created by Hill, Michael on 8/14/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MongooseDaemon.h"
#import "ScrubberControl.h"

typedef NS_ENUM(uint8_t, enumAppStatus) {
    sIdol,
    sRecording,
    sStopped,
    sPlaying,
};

@class RecordingSession;

@interface MasterViewController : NSViewController <NSTextFieldDelegate, ScrubberControlDelegate> {
    MongooseDaemon    *mongooseDaemon;
    
    NSTimer *recordingTimer;
    NSTimer *playbackTimer;
    
    bool isServerup;
    bool isFeedURLValid;
    
    enumAppStatus currentStatus;
    NSDate *currentPlaybackTime;
    NSString *lastFileCopiedForPlayback;
    
    NSString *lastFeedResponse;
    NSDate *lastResposeTime;
    
    RecordingSession *currentSession;
}

@property (strong, nonatomic) IBOutlet NSTextField *statusTextField;
@property (strong, nonatomic) IBOutlet NSTextField *feedTextField;

@property (strong, nonatomic) IBOutlet NSTextField *endimeTextField;

@property (strong, nonatomic) IBOutlet NSButton *recordButton;

@property (strong, nonatomic) IBOutlet NSView *progressContainer;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

-(void)updateWithSession:(RecordingSession *)newSession;
-(NSData *)dataForSave;

-(IBAction)progressAreaClickedAction:(id)sender;
-(IBAction)stopRecording:(id)sender;
-(IBAction)togglePlayback:(id)sender;
-(IBAction)stopPlaying:(id)sender;
-(IBAction)startRecording:(id)sender;
-(IBAction)textFieldDidChange:(id)sender;
-(IBAction)startServer:(id)sender;
-(IBAction)stopServer:(id)sender;

@end

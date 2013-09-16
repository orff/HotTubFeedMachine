//
//  MasterViewController.m
//  FeedSimulator
//
//  Created by Hill, Michael on 8/14/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//


//NOTES:
// Mongoose:
//  https://github.com/face/MongooseDaemon
//  http://myutil.com/2009/6/15/simple-way-to-embed-a-http-server-into-your-iphone-app
//  https://github.com/valenok/mongoose/blob/master/UserManual.md

// NSCoding
//  http://www.raywenderlich.com/1914/nscoding-tutorial-for-ios-how-to-save-your-app-data


#import "MasterViewController.h"
#import "ScrubberControl.h"


#import "AFNetworking.h"
#import "constants.h"

#import "RecordingSession.h"
#import "FeedResponse.h"

@implementation MasterViewController

#pragma mark helpers
-(void)updateWithSession:(RecordingSession *)newSession {
    NSLog(@"loading new session");
    
    currentSession = nil;
    currentSession = newSession;
    
    NSLog(@"session: %@", [currentSession description]);
    
    //update UI with new values
    if (currentSession.feedURL) self.feedTextField.stringValue =  currentSession.feedURL;
    
    if (currentSession.feedResponses.count > 0) {
        [self updateProgressBarWithNewData];
        currentStatus = sStopped;
    }
}

#pragma mark
#pragma mark UI stuff
+(void)alertBox:(NSString *)message {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText:message];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
}

-(void)updateServerStatus {
    isServerup ? [self.statusTextField setStringValue:@"HTTP server started"] : [self.statusTextField setStringValue:@"HTTP server stopped"];
}

-(void)updatePlaybackProgress:(float)progressPercent {
    NSLog(@"playback progress %2f", progressPercent);
    
    [self.progressIndicator setDoubleValue:progressPercent*100];
}

-(void)updateProgressBarWithNewData {
    //remove old tick marks
    for (NSView *v in self.progressContainer.subviews) {
        if ([v.identifier isEqualToString:@"progressMarkers"]) [v removeFromSuperview];
    }
    
    NSView *progressMarkerContainer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.progressContainer.frame.size.width, self.progressContainer.frame.size.height)];
    progressMarkerContainer.identifier = @"progressMarkers";
    //TODO: get this to work with constraints
//    progressMarkerContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
//    progressMarkerContainer.translatesAutoresizingMaskIntoConstraints = YES;
    
    //TODO: base this on times, and test with a feed that is changing!
    
    //redraw tick marks
    int cnt = 0;
    int startTimeInSecs = [currentSession.startTime timeIntervalSince1970];
    int padding = 2; // how mch to pad the end of the display
    
    for (FeedResponse *currentReponse in currentSession.feedResponses) {
        int responseTimeInSecs = [currentReponse.timeStamp timeIntervalSince1970];
        float barPercent = ((responseTimeInSecs - startTimeInSecs)*1.0) / [currentSession totalTimeForSessionInSeconds];
        float currentBarXpos = (int)(barPercent * (self.progressIndicator.frame.size.width-padding));
        
        //NSLog(@"barPercent %2f currentXpos %2f", barPercent, currentBarXpos);
        
        NSBox *verticalLine = [[NSBox alloc] initWithFrame:NSMakeRect(currentBarXpos, 20, 1, 20)];
        verticalLine.boxType = NSBoxSeparator;
        verticalLine.borderColor = [NSColor blackColor];
        [progressMarkerContainer addSubview:verticalLine];
        
        cnt++;
    }
    
    [self.progressContainer addSubview:progressMarkerContainer];
}

#pragma mark
#pragma mark Utility/Helpers
-(void)updateWithNewFeedResponse:(FeedResponse *)newResponse {
    //update current session with new response
    [currentSession addFeedResponse:newResponse]; //dont update property directly since it needs to bump endTime
    
    //update UI with new reponse
    [self updateProgressBarWithNewData];
}

-(void)recordFeed { //called when record feed timer fires
    NSLog(@"recordFeed fired!");
    
    NSURL *url = [NSURL URLWithString:self.feedTextField.stringValue];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *reqOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [reqOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // success
        if ((![lastFeedResponse isEqualToString:operation.responseString] && RECORD_ONLY_DIFFS) || !RECORD_ONLY_DIFFS) {
            lastFeedResponse = operation.responseString;
            NSLog(@"New response from feed");
            //NSLog(@"storing response: %@", lastFeedResponse);
            FeedResponse *fReponse = [[FeedResponse alloc] initWithFeedResponse:lastFeedResponse andURL:request.URL.absoluteString];
            fReponse.saved ? [self updateWithNewFeedResponse:fReponse] : NSLog(@"CANT SAVE RESPONSE");
        } else {
            NSLog(@"feed response same as last");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // FAIL
        
        NSLog(@"error: %@",  operation.responseString);
    }];
    [reqOperation start];
}

-(void)copyFileToDocumentsFolder:(NSString *)filenameToCopy {
    NSLog(@"copying file to documents folder: %@", filenameToCopy);
    
    NSString *source =[RAW_DOCUMENTS_FOLDER stringByAppendingPathComponent:filenameToCopy];
    NSString *destination = [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"output.xml"];
    
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:source]) {
        //if old file is at destination, delete it
        if ( [[NSFileManager defaultManager] isReadableFileAtPath:destination])
            [[NSFileManager defaultManager] removeItemAtPath:destination error:nil];
        
        [[NSFileManager defaultManager] copyItemAtPath:source toPath:destination error:nil];
    }
}

-(void)copyFileForPlayBackTime:(NSDate *)playbackTime {
    
    if ([playbackTime isEqualToDate:currentSession.startTime]) { //first time called in the beginning
        //just copy the first file
        
        if (currentSession.feedResponses.count>0) {
            lastFileCopiedForPlayback = ((FeedResponse *)[currentSession.feedResponses objectAtIndex:0]).filename; //filename of file copied
            [self copyFileToDocumentsFolder:lastFileCopiedForPlayback];
        }
    } else {
        // find the feed Response right before my time
        FeedResponse *reponseToPlay = [currentSession findFeedResponseToUseForPlaybackTime:playbackTime];
        
        if (reponseToPlay && ![lastFileCopiedForPlayback isEqualToString:reponseToPlay.filename]) {
            // copy that file
            lastFileCopiedForPlayback = reponseToPlay.filename; //filename of file copied
            [self copyFileToDocumentsFolder:lastFileCopiedForPlayback];
        }
    }
    
}

-(void)playbackFeed { //called when playback timer fires
    
    //TODO: this will be 1.0 / timeInterval ( inverse ) for fast forward ??
    double timeToAdd = playbackTimer.timeInterval;
    currentPlaybackTime = [currentPlaybackTime dateByAddingTimeInterval:timeToAdd];
    
    double startTimeInSec = [currentSession.startTime timeIntervalSince1970];
    double currentPlaybackTimeInSec = [currentPlaybackTime timeIntervalSince1970];
    
    float progress = ((currentPlaybackTimeInSec-startTimeInSec) / [currentSession totalTimeForSessionInSeconds]);
    
    if (progress > 100.0) { //at the end of playback
        [self togglePlayback:self];
        [self updatePlaybackProgress:1.0];
    } else {
        [self copyFileForPlayBackTime:currentPlaybackTime];
        [self updatePlaybackProgress:progress];
    }
}

-(void)setFeedStatusGood {
    isFeedURLValid = YES;
    [self.statusTextField setStringValue:@"Feed OK!"];
}

-(void)setFeedStatusBad {
    isFeedURLValid = NO;
    [self.statusTextField setStringValue:@"Bad response for feed!"];
}

#pragma mark mouse actions
-(void)scrubberDidUpdateAtPosition:(float)position {
    NSLog(@"scrubber did click: %2f",position);
    
    float posPercent = position / self.progressContainer.frame.size.width;
    float newTimeInSecs = [currentSession totalTimeForSessionInSeconds] * posPercent;
    
    currentPlaybackTime = [currentSession.startTime dateByAddingTimeInterval:newTimeInSecs];
    
    [self copyFileForPlayBackTime:currentPlaybackTime];
    [self updatePlaybackProgress:posPercent];

}

#pragma mark IBActions
-(IBAction)progressAreaClickedAction:(id)sender {
    NSLog(@"clicked progress ");
}

-(IBAction)stopRecording:(id)sender {
    currentStatus = sStopped;
    
    if (recordingTimer) { [recordingTimer invalidate]; recordingTimer = nil; }
    [self.statusTextField setStringValue:@"Stopped Recording!"];
}

-(IBAction)togglePlayback:(id)sender {
    NSLog(@"start play button mashed");
    
    if (currentStatus == sIdol) {
        //complain:havent loaded OR recorded -- would be stopped
        [MasterViewController alertBox:@"You must load or record some feeds."];
        
        return;
    }
    
    if (currentStatus == sRecording) {
        //complain ?
        [MasterViewController alertBox:@"You must stop your recording."];
        
        return;
    }
    
    if (currentStatus == sStopped) {
        //start playing
        
        currentStatus = sPlaying;
        
        currentPlaybackTime = currentSession.startTime;
        [self copyFileForPlayBackTime:currentPlaybackTime];
        
        if (playbackTimer) { [playbackTimer invalidate]; playbackTimer = nil; }
        
        //TODO support faster speeds
        NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(recordFeed)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sgn];
        [inv setTarget: self];
        [inv setSelector:@selector(playbackFeed)];
        
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:inv repeats:YES];
//        [playbackTimer fire]; //fire one off now!
        NSLog(@"timer started for playback %@", [playbackTimer description]);
        
        return;
    }
    
    if (currentStatus == sPlaying) {
        //stop playing
        [self stopPlaying:self];
        
        return;
    }
}

-(IBAction)stopPlaying:(id)sender {
    NSLog(@"stop play button mashed");
    currentStatus = sStopped;
    if (playbackTimer) { [playbackTimer invalidate]; playbackTimer = nil; }
}


-(IBAction)startRecording:(id)sender {
    NSLog(@"start recording button mashed");
    
    NSString *feedURL = self.feedTextField.stringValue;
    
    NSLog(@"URL: %@", feedURL);
    
    //validate feed!
    if (isFeedURLValid) {
        currentStatus = sRecording;
        
        if (recordingTimer) { [recordingTimer invalidate]; recordingTimer = nil; }
        
        //start timer!
        NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(recordFeed)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sgn];
        [inv setTarget: self];
        [inv setSelector:@selector(recordFeed)];
        
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 invocation:inv repeats:YES];
        [recordingTimer fire]; //fire one off now!
        NSLog(@"timer started for recording %@", [recordingTimer description]);
        
        [self.statusTextField setStringValue:@"Recording!"];
    } else {
        [MasterViewController alertBox:@"You must set a valid feed to record (and click SET)."];
    }
}

-(IBAction)textFieldDidChange:(id)sender {
    NSLog(@"textFieldDidChange");
    
    NSURL *url = [NSURL URLWithString:self.feedTextField.stringValue];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *reqOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [reqOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setFeedStatusGood];
        NSLog(@"Feed OK");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setFeedStatusBad];
    }];
    
    [reqOperation start];
    
    //update feedURL in session
    currentSession.feedURL = self.feedTextField.stringValue;
}

-(IBAction)startServer:(id)sender {
    NSLog(@"start server button mashed");
    
    isServerup = YES;
    [self updateServerStatus];
    [mongooseDaemon startMongooseDaemon:@"8080"];
}

-(IBAction)stopServer:(id)sender {
    NSLog(@"stop server button mashed");
    
    if (!isServerup) return;
    
    [mongooseDaemon stopMongooseDaemon];
    isServerup = NO;
    currentStatus = sIdol;
    [self updateServerStatus];
}

//called from main document to save the file
-(NSData *)dataForSave {
    NSLog(@"saving data: %@", [currentSession description]);
    return [NSKeyedArchiver archivedDataWithRootObject:currentSession];
}


#pragma mark controller pipeline
-(void)loadView {
    [super loadView];
    
    //set progress indicator id
    self.progressIndicator.identifier = @"progressInd";
    
    CGRect scrubberFrame = self.progressContainer.frame;
    scrubberFrame.origin = CGPointZero;
    ScrubberControl *scrubberControl = [[ScrubberControl alloc] initWithFrame:scrubberFrame];
    scrubberControl.delegate = self;
    [self.progressContainer addSubview:scrubberControl];
    
    [self updateServerStatus];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        mongooseDaemon = [[MongooseDaemon alloc] init];
        isServerup= NO;
        isFeedURLValid = NO;
        lastFeedResponse = @"";
    }
    
    return self;
}

@end

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

#import "AFNetworking.h"
#import "constants.h"

#import "RecordingSession.h"
#import "FeedResponse.h"

@implementation MasterViewController

#pragma mark helpers

-(void)updateWithData:(NSData *)dataToUnarchive {
    NSLog(@"loading new session");
    
    self.feedTextField.stringValue = @"new session loaded";
}

//called from main document to save the file
-(NSData *)dataForSave {
    return [NSKeyedArchiver archivedDataWithRootObject:currentSession];
}

-(void)updateWithNewFeedResponse:(FeedResponse *)newResponse {
    //update current session with new response
    [currentSession addFeedResponse:newResponse];
    
    //update UI with new reponse
    
    //remove old tick marks    
    for (NSView *v in self.progressContainer.subviews) {
        if ([v.identifier isEqualToString:@"progressMarkers"]) [v removeFromSuperview];
    }
    
    NSView *progressMarkerContainer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.progressContainer.frame.size.width, self.progressContainer.frame.size.height)];
    progressMarkerContainer.identifier = @"progressMarkers";
    
    //TODO: base this on times, and test with a feed that is changing!
    
    //redraw tick marks
    int cnt = 0;
    NSArray *currentResponses = [currentSession getFeedResponses];
    for (FeedResponse *currentReponse in currentResponses) {
        float barPercent = ((cnt + 1) / (currentResponses.count*1.0));
        float currentBarXpos = barPercent * self.progressIndicator.frame.size.width;
        
        //NSLog(@"barPercent %2f currentXpos %2f", barPercent, currentBarXpos);
        
        NSBox *verticalLine = [[NSBox alloc] initWithFrame:NSMakeRect(currentBarXpos, 15, 2, 30)];
        verticalLine.borderColor = [NSColor blackColor];
        [progressMarkerContainer addSubview:verticalLine];
        
        cnt++;
    }
    
    [self.progressContainer addSubview:progressMarkerContainer];

}

-(void)recordFeed {
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

-(void)updateServerStatus {
    isServerup ? [self.statusTextField setStringValue:@"HTTP server started"] : [self.statusTextField setStringValue:@"HTTP server stopped"];
}

-(void)createAppHomeFolder {
    BOOL isDir = NO;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DOCUMENTS_FOLDER isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:DOCUMENTS_FOLDER withIntermediateDirectories:YES attributes:nil error:NULL])
            [self.statusTextField setStringValue:[NSString stringWithFormat:@"Create folder: %@ FAILED!", DOCUMENTS_FOLDER]];
        //create raw storage folder
    [fileManager createDirectoryAtPath:RAW_DOCUMENTS_FOLDER withIntermediateDirectories:YES attributes:nil error:NULL];
    [self.statusTextField setStringValue:[NSString stringWithFormat:@"folder created: %@", DOCUMENTS_FOLDER]];
}

-(void)setFeedStatusGood {
    isFeedURLValid = YES;
    [self.statusTextField setStringValue:@"Feed OK!"];
}

-(void)setFeedStatusBad {
    isFeedURLValid = NO;
    [self.statusTextField setStringValue:@"Bad response for feed!"];
}

-(void)alertBox:(NSString *)message {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText:message];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
}

#pragma mark IBActions
-(IBAction)stopRecording:(id)sender {
    currentStatus = sStopped;
    
    if (recordingTimer) { [recordingTimer invalidate]; recordingTimer = nil; }
    [self.statusTextField setStringValue:@"Stopped Recording!"];
}

-(IBAction)togglePlayback:(id)sender {
    NSLog(@"start play button mashed");
    
    if (currentStatus == sIdol) {
        //complain:havent loaded OR recorded -- would be stopped
        [self alertBox:@"You must load or record some feeds."];
    }
    
    if (currentStatus == sRecording) {
        //complain ?
        [self alertBox:@"You must stop your recording."];
    }
    
    if (currentStatus == sStopped) {
        //start playing
        
        currentStatus = sPlaying;
    }
    
    if (currentStatus == sPlaying) {
        //stop playing
        
        currentStatus = sPlaying;
    }
}

-(IBAction)stopPlaying:(id)sender {
    NSLog(@"stop play button mashed");
}


-(IBAction)startRecording:(id)sender {
    NSLog(@"start recording button mashed");
    
    NSString *feedURL = self.feedTextField.stringValue;
    
    NSLog(@"URL: %@", feedURL);
    
    //validate feed!
    if (isFeedURLValid) {
        currentStatus = sRecording;
        
        currentSession = [[RecordingSession alloc] initWithFeedURL:feedURL];
        
        //start timer!
        NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(recordFeed)];
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sgn];
        [inv setTarget: self];
        [inv setSelector:@selector(recordFeed)];
        
        if (recordingTimer) { [recordingTimer invalidate]; recordingTimer = nil; }
        
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 invocation:inv repeats:YES];
        [recordingTimer fire]; //fire one off now!
        NSLog(@"timer started for recording %@", [recordingTimer description]);
        
        [self.statusTextField setStringValue:@"Recording!"];
    } else {
        [self alertBox:@"You must set a valid feed to record (and click SET)."];
    }
}

-(IBAction)textFieldDidChange:(id)sender {
    NSLog(@"textFieldDidChange");
    
    NSURL *url = [NSURL URLWithString:self.feedTextField.stringValue];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //TODO: convert this to a regular HTTP request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self setFeedStatusGood];
        NSLog(@"Feed OK: IP Address: %@", [JSON valueForKeyPath:@"origin"]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self setFeedStatusBad];
    }];
    
    [operation start];
}

-(IBAction)startServer:(id)sender {
    NSLog(@"start server button mashed");
    
    isServerup = YES;
    [self updateServerStatus];
    [mongooseDaemon startMongooseDaemon:@"8080"];
}

-(IBAction)stopServer:(id)sender {
    NSLog(@"stop server button mashed");
    
    [mongooseDaemon stopMongooseDaemon];
    isServerup = NO;
    currentStatus = sIdol;
    [self updateServerStatus];
}

#pragma mark controller pipeline
-(void)loadView {
    [super loadView];
    
    //set progress indicator id
    self.progressIndicator.identifier = @"progressInd";
    
    [self updateServerStatus];
    [self createAppHomeFolder];
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

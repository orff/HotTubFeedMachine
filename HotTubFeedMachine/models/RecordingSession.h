//
//  RecordingSession.h
//  FeedSimulator
//
//  Created by Hill, Michael on 8/28/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedResponse;

@interface RecordingSession : NSObject <NSCoding> {
    NSMutableArray *feedResponses;
}

@property (readonly) NSDate *startTime;
@property (readonly) NSString *feedURL; //eventually will need to be an array
@property (readonly) NSDate *endTime;

-(id)initWithFeedURL:(NSString *)urlString;

-(void)addFeedResponse:(FeedResponse *)newResponse;

-(NSArray *)getFeedResponses;

@end

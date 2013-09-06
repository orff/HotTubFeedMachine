//
//  RecordingSession.m
//  FeedSimulator
//
//  Created by Hill, Michael on 8/28/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "RecordingSession.h"
#import "FeedResponse.h"

@implementation RecordingSession

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:feedResponses forKey:@"feedResponses"];
    
    [encoder encodeObject:self.startTime forKey:@"startTime"];
    [encoder encodeObject:self.endTime forKey:@"endTime"];
    [encoder encodeObject:self.feedURL forKey:@"feedURL"];
    
}

-(id)initWithCoder:(NSCoder *)decoder {
    NSString *feedURL = [decoder decodeObjectForKey:@"feedURL"];
    
    self = [self initWithFeedURL:feedURL];
    
    [feedResponses addObjectsFromArray:[decoder decodeObjectForKey:@"feedResponses"]];
    _startTime = [decoder decodeObjectForKey:@"startTime"];
    _endTime = [decoder decodeObjectForKey:@"endTime"];
    
    return self;
}

-(NSArray *)getFeedResponses {
    return [NSArray arrayWithArray:feedResponses];
}

- (id)initWithFeedURL:(NSString *)urlString
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        feedResponses = [[NSMutableArray alloc] init];
        
        _startTime = [NSDate date];
        _feedURL = urlString;
    }
    
    return self;
}

-(void)addFeedResponse:(FeedResponse *)newResponse {
    [feedResponses addObject:newResponse];
    
    //update end time
    _endTime = newResponse.timeStamp;
}

@end

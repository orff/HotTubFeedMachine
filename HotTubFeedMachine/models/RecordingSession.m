//
//  RecordingSession.m
//  FeedSimulator
//
//  Created by Hill, Michael on 8/28/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "RecordingSession.h"
#import "FeedResponse.h"
#import "constants.h"

@implementation RecordingSession

-(FeedResponse *)findFeedResponseToUseForPlaybackTime:(NSDate *)playbackTime {
    //TODO: this is slow, use a while loop or something better to speed it up
    int foundIndex=-1;
    int cnt=0;
    for (FeedResponse *currentResponse in self.feedResponses) {
        if ([currentResponse.timeStamp isLessThan:playbackTime]) foundIndex = cnt;
        cnt++;
    }
    if (foundIndex>-1) return [self.feedResponses objectAtIndex:foundIndex];
    
    //none found or no reponses
    return nil;
}

-(double)totalTimeForSessionInSeconds {
    return [self.endTime timeIntervalSince1970] - [self.startTime timeIntervalSince1970];
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.feedResponses forKey:@"feedResponses"];
    
    [encoder encodeObject:self.startTime forKey:@"startTime"];
    [encoder encodeObject:self.endTime forKey:@"endTime"];
    [encoder encodeObject:self.feedURL forKey:@"feedURL"];
    [encoder encodeObject:self.feedType forKey:@"feedType"];
    
}

-(id)init {
    self = [super init];
    
    _feedType = DEFAULT_FEED_TYPE;
    _startTime = [NSDate date];
    _endTime = _startTime;
    _feedResponses = [[NSMutableArray alloc] init];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    
    [_feedResponses addObjectsFromArray:[decoder decodeObjectForKey:@"feedResponses"]];
    _startTime = [decoder decodeObjectForKey:@"startTime"];
    _endTime = [decoder decodeObjectForKey:@"endTime"];
    _feedURL = [decoder decodeObjectForKey:@"feedURL"];
    NSString *tmpFeedType = [decoder decodeObjectForKey:@"feedType"];
    if (!tmpFeedType) tmpFeedType = DEFAULT_FEED_TYPE;
    _feedType = tmpFeedType;
    
    return self;
}

-(void)addFeedResponse:(FeedResponse *)newResponse {
    [self.feedResponses addObject:newResponse];
    
    //update end time
    _endTime = newResponse.timeStamp;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"feedURL: %@ type: %@ responses %i startTime %@ endTime %@", _feedURL, _feedType, (int)_feedResponses.count, [_startTime description], [_endTime description]];
}

@end

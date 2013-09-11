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
    
}

@property (readonly) NSDate *startTime;
@property (readonly) NSDate *endTime;

@property (nonatomic, strong) NSString *feedURL; //eventually will need to be an array
@property (nonatomic, readonly) NSMutableArray *feedResponses;

-(void)addFeedResponse:(FeedResponse *)newResponse;

@end

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
@property (nonatomic, strong) NSString *feedURL; //eventually will need to be an array
@property (nonatomic, strong) NSMutableArray *feedResponses;
@property (readonly) NSDate *endTime;

@end

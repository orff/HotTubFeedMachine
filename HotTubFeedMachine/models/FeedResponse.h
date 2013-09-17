//
//  FeedResponse.h
//  FeedSimulator
//
//  Created by Hill, Michael on 8/19/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedResponse : NSObject

@property (strong, nonatomic) NSDate *timeStamp;
@property (strong, nonatomic) NSString *filename;

@property (readonly) bool saved;

+(void)copyFileToDocumentsFolder:(NSString *)filenameToCopy;
-(id)initWithFeedResponse:(NSString *)feedResponse andURL:(NSString *)urlString;

@end

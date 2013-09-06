//
//  FeedResponse.m
//  FeedSimulator
//
//  Created by Hill, Michael on 8/19/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "FeedResponse.h"
#import "constants.h"

@implementation FeedResponse

-(NSString *)filenameForURL:(NSString *)urlString {
    //TODO: use URL as part of the filename
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"response-%@.json", dateString];
}

-(void)saveResponseToFile:(NSString *)feedResponse {
    
    NSLog(@"response saved to %@", self.filename);
    
    NSString *results=[RAW_DOCUMENTS_FOLDER stringByAppendingPathComponent:self.filename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:results]) {
        [[NSFileManager defaultManager]
         createFileAtPath:results contents:nil attributes:nil];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:results];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[feedResponse dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
        NSLog(@"info saved");
    }
    
    _saved = YES;
}

-(void)encodeWithCoder:(NSCoder *)encoder {    
    [encoder encodeObject:self.timeStamp forKey:@"timeStamp"];
    [encoder encodeObject:self.filename forKey:@"filename"];
}

-(id)initWithCoder:(NSCoder *)decoder {    
    self = [super init];

    self.timeStamp = [decoder decodeObjectForKey:@"timeStamp"];
    self.filename = [decoder decodeObjectForKey:@"filename"];
    
    return self;
}

-(id)initWithFeedResponse:(NSString *)feedResponse andURL:(NSString *)urlString
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.timeStamp = [NSDate date];
        self.filename = [self filenameForURL:urlString];
        
        [self saveResponseToFile:feedResponse];
    }
    
    return self;
}

@end

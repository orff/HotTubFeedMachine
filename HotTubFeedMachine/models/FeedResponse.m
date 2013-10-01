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

+(void)copyFileToDocumentsFolder:(NSString *)filenameToCopy {
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

-(NSString *)filenameForURL:(NSString *)urlString andType:(NSString *)feedType {
    //TODO: use URL as part of the filename
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"response-%@.%@", dateString, feedType];
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
    
    //add in the file itself, load it from the fileSystem in case it changed
    NSString *results=[RAW_DOCUMENTS_FOLDER stringByAppendingPathComponent:self.filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:results]) {
        NSData *databuffer = [[NSFileManager defaultManager] contentsAtPath:results];
        [encoder encodeObject:databuffer forKey:@"fileContents"];
    }
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    self.timeStamp = [decoder decodeObjectForKey:@"timeStamp"];
    self.filename = [decoder decodeObjectForKey:@"filename"];
    
    //create the file
    NSData *dataBuffer = [decoder decodeObjectForKey:@"fileContents"];
    if (dataBuffer) {
        NSString *results=[RAW_DOCUMENTS_FOLDER stringByAppendingPathComponent:self.filename];
        [[NSFileManager defaultManager] createFileAtPath:results contents:dataBuffer attributes: nil];
    }
    
    return self;
}

-(id)initWithFeedResponse:(NSString *)feedResponse type:(NSString *)feedType andURL:(NSString *)urlString {
    self = [super init];
    if (self) {
        // Initialization code here.
        self.timeStamp = [NSDate date];
        self.filename = [self filenameForURL:urlString andType:feedType];
        
        [self saveResponseToFile:feedResponse];
    }
    
    return self;
}

@end

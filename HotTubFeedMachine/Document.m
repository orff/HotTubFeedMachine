//
//  Document.m
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/6/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "Document.h"
#import "MasterViewController.h"
#import "RecordingSession.h"
#import "constants.h"
#import "HTUtils.h"

@implementation Document

-(void)createAppHomeFolder {
    BOOL isDir = NO;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DOCUMENTS_FOLDER isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:DOCUMENTS_FOLDER withIntermediateDirectories:YES attributes:nil error:NULL]) {
            [HTUtils alertBox:[NSString stringWithFormat:@"Create folder: %@ FAILED!", DOCUMENTS_FOLDER]];
        } else {
            //create raw storage folder
            if(![fileManager createDirectoryAtPath:RAW_DOCUMENTS_FOLDER withIntermediateDirectories:YES attributes:nil error:NULL])
                [HTUtils alertBox:[NSString stringWithFormat:@"Create raw docs folder: %@ FAILED!", RAW_DOCUMENTS_FOLDER]];
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        
        currentSession = [[RecordingSession alloc] init];
        
        [self createAppHomeFolder];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    NSLog(@"windowControllerDidLoadNib");
    
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.masterViewController.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    [self.masterViewController updateWithSession:currentSession];
    
    [aController.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)aController.window.contentView).bounds;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    NSData *saveData = [self.masterViewController dataForSave];
    return saveData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    //NSLog(@"readFromData called");
    
    currentSession = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return YES;
}

@end

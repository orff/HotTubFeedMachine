//
//  HTHelper.m
//  HotTubFeedMachine
//
//  Created by Hill, Michael on 9/17/13.
//  Copyright (c) 2013 Hill, Michael. All rights reserved.
//

#import "HTUtils.h"

@implementation HTUtils

+(void)alertBox:(NSString *)message {
    NSAlert* msgBox = [[NSAlert alloc] init];
    [msgBox setMessageText:message];
    [msgBox addButtonWithTitle: @"OK"];
    [msgBox runModal];
}

+(void)addAutoLayoutConstraintsToView:(NSView *)subView withSuperView:(NSView *)superview {
    
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:subView];
    
    //[progressMarkerContainer setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    //    NSDictionary *views = NSDictionaryOfVariableBindings(subView);
    //    [self.progressContainer addConstraints:
    //     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressMarkerContainer]|"
    //                                             options:0
    //                                             metrics:nil
    //                                               views:views]];
    //
    //    [self.progressContainer addConstraints:
    //     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressMarkerContainer]|"
    //                                             options:0
    //                                             metrics:nil
    //                                               views:views]];
    
    [superview addConstraint:
     [NSLayoutConstraint constraintWithItem:subView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:superview
                                  attribute:NSLayoutAttributeWidth
                                 multiplier:1
                                   constant:0]];
    [superview addConstraint:
     [NSLayoutConstraint constraintWithItem:subView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:superview
                                  attribute:NSLayoutAttributeHeight
                                 multiplier:1
                                   constant:0]];
    
    [self addEdgeConstraint:NSLayoutAttributeLeft superview:superview subview:subView];
    [self addEdgeConstraint:NSLayoutAttributeRight superview:superview subview:subView];
    [self addEdgeConstraint:NSLayoutAttributeTop superview:superview subview:subView];
    [self addEdgeConstraint:NSLayoutAttributeBottom superview:superview subview:subView];
    
    [subView updateConstraints];
}

+(void)addEdgeConstraint:(NSLayoutAttribute)edge superview:(NSView *)superview subview:(NSView *)subview {
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:0]];
}


@end

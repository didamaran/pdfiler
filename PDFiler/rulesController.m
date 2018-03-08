//
//  rulesController.m
//  PDFiler
//
//  Created by Tom Nakat on 24.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "rulesController.h"
#import "renamerBrain.h"

@implementation rulesController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _brain = [[renamerBrain alloc] init];
        _regeln = [[NSMutableDictionary alloc] initWithDictionary:[_brain getRegeln]];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    jsmDebug(@"windowDidLoad");
    [_dict bind:NSContentDictionaryBinding toObject:self withKeyPath:@"regeln" options:nil];
}


-(BOOL) windowShouldClose:(NSNotification *)notification {
    BOOL r = YES;
    jsmDebug(@"should close");
    return r;
}


@end

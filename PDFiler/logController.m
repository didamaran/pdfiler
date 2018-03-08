//
//  logController.m
//  PDFiler
//
//  Created by Tom Nakat on 24.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "logController.h"


@implementation logController

static NSString *appSupportDir;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.window setBackgroundColor:[NSColor whiteColor]];

    // Initialization code here.
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    appSupportDir = [paths objectAtIndex:0];

    NSString *logPath = [NSString stringWithFormat:@"%@/PDFiler/log.txt", appSupportDir];
    //jsmDebug(@"%@", logPath);
    if( [fm fileExistsAtPath: logPath ] ) {
        NSString *logdata = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
        [_log insertText:logdata];
    } else {
        [_log insertText:@"No log-data available"];
    }
}

@end

//
//  updateController.m
//  PDFiler
//
//  Created by Tom Nakat on 22.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "updateController.h"

@interface updateController ()

@end

@implementation updateController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSString *value = [NSString stringWithFormat:@"You are using Version %@.%@",
                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
                       ];
    [_httpResponse setStringValue:value];

    NSString *myVersion = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    NSString *ret;
    NSError* error = nil;
    NSURL *url = [NSURL URLWithString:@"http://www.pdfiler.de/versioncheck.php"];
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error) {
        ret = @"No internet connection, unable to check for update!";
    } else {
        [_progressbar setHidden:TRUE];
        ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //jsmDebug(@"|%@| = |%@|", myVersion, ret);
        if ( [ret isEqualToString:myVersion] ) {
            ret = @"This is the most recent version of PDFiler";
        } else {
            ret = @"There is a newer version of PDFiler available!";
            [_button setHidden:FALSE];
        }
    }
    value = [value stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", ret]];
    [_httpResponse setStringValue:value];

}


- (IBAction)goToDownload:(id)sender {
    [self.window orderOut: nil];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.pdfiler.de/download.html"]];
}

@end

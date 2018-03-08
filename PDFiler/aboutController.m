//
//  aboutController.m
//  PDFiler
//
//  Created by Tom Nakat on 19.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "aboutController.h"


@implementation aboutController

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
    
    NSString *value;
    value = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (value != nil)
    {
        [_versionLabel setStringValue: [NSString stringWithFormat:@"PDFiler Version %@ (build %@)", value,
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    }
    [_nameDateLabel setStringValue: [NSString stringWithFormat:@"Copyright ©2013 zenzible   All rights reserved"]];
}

- (IBAction)twitterButton:(id)sender {
    [self.window orderOut: nil];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://twitter.com/PDFiler"]];
}
- (IBAction)pdfilerButton:(id)sender {
    [self.window orderOut: nil];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.pdfiler.de"]];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown: (NSEvent *)event
{
    [self.window orderOut: nil];
    [super mouseDown:event];
}

- (void)keyDown: (NSEvent *)event
{
    [self.window orderOut: nil];
    [super keyDown:event];
}

@end

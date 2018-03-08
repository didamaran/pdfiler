//
//  updateController.h
//  PDFiler
//
//  Created by Tom Nakat on 22.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface updateController : NSWindowController

@property (weak) IBOutlet NSTextField *httpResponse;
@property (weak) IBOutlet NSProgressIndicator *progressbar;
@property (weak) IBOutlet NSButton *button;

@end

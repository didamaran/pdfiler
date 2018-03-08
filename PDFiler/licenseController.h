//
//  licenseController.h
//  PDFiler
//
//  Created by Tom Nakat on 23.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface licenseController : NSWindowController

@property (weak) IBOutlet NSTextField *email;
@property (weak) IBOutlet NSTextField *licensecode;
@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSButton *buyButton;
@property (weak) IBOutlet NSButton *unlockButton;
@property (weak) IBOutlet NSButton *cancelButton;

@end

//
//  aboutController.h
//  PDFiler
//
//  Created by Tom Nakat on 19.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface aboutController : NSWindowController <NSWindowDelegate>


@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSTextField *nameDateLabel;


@end

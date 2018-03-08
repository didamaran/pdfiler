//
//  AppDelegate.h
//  PDFiler
//
//  Created by Tom Nakat on 10.10.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class mainWindowController;
@class PrefController;
@class licenseController;
@class rulesController;
@class logController;
@class updateController;
@class aboutController;


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    mainWindowController *_mainWindowController;
}

@property (nonatomic, readonly) mainWindowController *mainWindowController;

@property (nonatomic, readonly) PrefController *PrefController;
@property (nonatomic, readonly) licenseController *licenseController;
@property (nonatomic, readonly) rulesController *rulesController;
@property (nonatomic, readonly) logController *logController;
@property (nonatomic, readonly) updateController *updateController;
@property (nonatomic, readonly) aboutController *aboutController;

@end

//
//  PrefController.m
//  PDFiler
//
//  Created by Tom Nakat on 11.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "PrefController.h"
#import "Constants.h"
#import "renamerBrain.h"


@implementation PrefController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _brain = [[renamerBrain alloc] init];
    }
    
    return self;
}


//NSURL will return nil for URLs that contain illegal chars, like spaces.
//Before using your string with [NSURL URLWithString:] make sure to escape all the disallowed chars by using [NSString stringByAddingPercentEscapesUsingEncoding:].

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSString *mandant = [_brain getMandant];
    NSString *appSupportDir = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ( [mandant isEqualToString:@""] ) {
        appSupportDir = [NSString stringWithFormat:@"%@/PDFiler", [paths objectAtIndex:0]];
    } else {
        appSupportDir = [NSString stringWithFormat:@"%@/PDFiler/%@", [paths objectAtIndex:0], mandant];
    }
    NSError *error = nil;
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:appSupportDir];
    if ( !fh ) {
        [fm createDirectoryAtPath:appSupportDir withIntermediateDirectories:YES attributes:nil error:&error];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *sourcePathString = [defaults stringForKey:PREF_SOURCE];
    if (sourcePathString == nil || [sourcePathString isEqualToString:@""] )
    {
        NSArray *standardpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        sourcePathString = [standardpath objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject: sourcePathString
                                                  forKey:PREF_SOURCE];
    }
    NSURL* url1 = [[NSURL alloc] initFileURLWithPath:sourcePathString];
    [_sourceFolderValue setStringValue: [url1 lastPathComponent]];

    NSString *targetPathString = [defaults stringForKey:PREF_TARGET];
    if (targetPathString == nil || [targetPathString isEqualToString:@""] )
    {
        NSArray *standardpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        targetPathString = [standardpath objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject: targetPathString
                                                  forKey:PREF_TARGET];
    }
    NSURL* url2 = [[NSURL alloc] initFileURLWithPath:targetPathString];
    [_targetRootValue setStringValue: [url2 lastPathComponent]];

    NSString *glue = [defaults stringForKey:PREF_SEPARATOR];
    if (glue == nil || [glue isEqualToString:@""] ) {
        glue = @"-";
        [[NSUserDefaults standardUserDefaults] setObject:glue
                                                  forKey:PREF_SEPARATOR];
    }
    [_glueCharacter setStringValue:glue];
    [_glueCharacterDemo setStringValue: [NSString stringWithFormat:@"YYYY%@MM%@DD", glue, glue]];

    NSString *screenmode = [defaults stringForKey:PREF_FULLSCREEN];
    if (screenmode == nil || [screenmode isEqualToString:@""] ) {
        screenmode = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:screenmode
                                                  forKey:PREF_FULLSCREEN];
    }
    if ( [screenmode isEqualToString:@"1"] ) {
        [_fullscreenCheckbox setState:1];
    } else {
        [_fullscreenCheckbox setState:0];
    }


}

-(BOOL) windowShouldClose:(NSNotification *)notification
{
    if( [BTARGET isEqualToString:@"HN"] || [BTARGET isEqualToString:@"DPA"] ) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *currentMandant = [ud stringForKey:PREF_MAN];
        jsmDebug(@"windowShouldClose from %@", currentMandant);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *prefsPath = [NSString stringWithFormat:@"%@/PDFiler/%@/prefs.plist", [paths objectAtIndex:0], currentMandant];
        NSMutableDictionary *mprefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
        [mprefs setObject:[ud stringForKey:PREF_SEPARATOR] forKey:PREF_SEPARATOR];
        [mprefs setObject:[ud stringForKey:PREF_SOURCE] forKey:PREF_SOURCE];
        [mprefs setObject:[ud stringForKey:PREF_TARGET] forKey:PREF_TARGET];
        [mprefs writeToFile:prefsPath atomically:YES];
    }
    return YES;
}


- (void)controlTextDidChange:(NSNotification *)obj
{
    NSString *glue = [_glueCharacter stringValue];
    [_glueCharacterDemo setStringValue: [NSString stringWithFormat:@"YYYY%@MM%@DD", glue, glue]];
    [[NSUserDefaults standardUserDefaults] setObject:glue
                                              forKey:PREF_SEPARATOR];
}



- (IBAction)selectSourceFolder:(id)sender {
    NSURL *url = [self chooseFolder];
    NSError *err;
    if ([url checkResourceIsReachableAndReturnError:&err] == NO) {
        jsmDebug(@"choose folder wurde abgebrochen");
    } else {
        _sourcePath = url;
        [_sourceFolderValue setStringValue: [url lastPathComponent]];
        [[NSUserDefaults standardUserDefaults] setObject: [url path]
                                                  forKey:PREF_SOURCE];
    }
}

- (IBAction)selectTargetRoot:(id)sender {
    NSURL *url = [self chooseFolder];
    NSError *err;
    if ([url checkResourceIsReachableAndReturnError:&err] == NO) {
        jsmDebug(@"choose folder wurde abgebrochen");
    } else {
        _targetPath = url;
        [_targetRootValue setStringValue: [url lastPathComponent]];
        [[NSUserDefaults standardUserDefaults] setObject: [url path]
                                                  forKey:PREF_TARGET];
    }
}

- (IBAction)setScreenmode:(id)sender {
    NSString *screenmode = [_fullscreenCheckbox stringValue];
    jsmDebug(@"screenmode %@", screenmode);
    [[NSUserDefaults standardUserDefaults] setObject:screenmode
                                              forKey:PREF_FULLSCREEN];
}

- (NSURL*) chooseFolder {
    NSOpenPanel *panel = [NSOpenPanel openPanel]; //Create open panel dialog
    [panel setCanChooseFiles: false]; //Disable file selection
    [panel setCanChooseDirectories: true]; //Enable folder selection
    [panel setResolvesAliases: true]; //Enable alias resolving
    [panel setAllowsMultipleSelection: false]; //Disable multiple selection
    NSInteger result = [panel runModal]; //Display open panel

    if (result == NSFileHandlingPanelOKButton) {
        NSArray* urls = [panel URLs];
        NSURL *url = [urls objectAtIndex:0];
        jsmDebug(@"%@", url);
        if (url != nil) {
            return url;
        }
    }
    return nil;
}


@end

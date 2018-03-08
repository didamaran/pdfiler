//
//  AppDelegate.m
//  PDFiler
//
//  Created by Tom Nakat on 10.10.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "AppDelegate.h"

#import "Constants.h"
#import "mainWindowController.h"
#import "PrefController.h"
#import "licenseController.h"
#import "rulesController.h"
#import "logController.h"
#import "updateController.h"
#import "aboutController.h"


@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionary];
        [prefs setObject:@"-" forKey:PREF_SEPARATOR];
        [prefs setObject:@"" forKey:PREF_SOURCE];
        [prefs setObject:@"" forKey:PREF_TARGET];
        [prefs setObject:@"0" forKey:PREF_FULLSCREEN];
        [prefs setObject:@"" forKey:PREF_MAN];
        [prefs setObject:@"magari" forKey:UD_VABENE];
        [prefs setObject:@"paste your license code here" forKey:UD_MAIL];
        [prefs setObject:@"your.email@address.com" forKey:UD_REGCODE];
        
        //         wenn noch keine prefs vorhanden sind, den folder
        //         ~/User/Documents als Standardfolder für sourcefolder + targetfolder hernehmen
        NSArray *standardpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [standardpath objectAtIndex:0];
        [prefs setObject:documentsPath forKey:PREF_SOURCE];
        [prefs setObject:documentsPath forKey:PREF_TARGET];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
    }
    return self;
}


- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    _mainWindowController = [[mainWindowController alloc] initWithWindowNibName:@"mainWindow"];
    [_mainWindowController showWindow:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *screenmode = [defaults stringForKey:PREF_FULLSCREEN];
    if ( [screenmode isEqualToString:@"1"] ) {
        [_mainWindowController.window  setFrame:[[NSScreen mainScreen] visibleFrame] display:YES]; // open maximized
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //[self showUpdate]
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (IBAction)showPrefs:(id)sender {
    _PrefController = [[PrefController alloc] initWithWindowNibName:@"PrefController"];
    [_PrefController showWindow:self];
}

- (IBAction)showLicense:(id)sender {
    _licenseController = [[licenseController alloc] initWithWindowNibName:@"licenseController"];
    [_licenseController showWindow:self];
}


- (IBAction)showRules:(id)sender {
    _rulesController = [[rulesController alloc] initWithWindowNibName:@"rulesController"];
    [_rulesController showWindow:self];
}

- (IBAction)showLog:(id)sender {
    _logController = [[logController alloc] initWithWindowNibName:@"logController"];
    [_logController showWindow:self];
}

- (IBAction)showUpdate:(id)sender {
    _updateController = [[updateController alloc] initWithWindowNibName:@"updateController"];
    [_updateController showWindow:self];
}

- (IBAction)showAbout:(id)sender {
    _aboutController = [[aboutController alloc] initWithWindowNibName:@"aboutController"];
    [_aboutController showWindow:self];
}

@end

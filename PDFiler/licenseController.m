//
//  licenseController.m
//  PDFiler
//
//  Created by Tom Nakat on 23.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "licenseController.h"
#import "Constants.h"
#import <CommonCrypto/CommonDigest.h> // für sha1

@interface licenseController ()

@end

@implementation licenseController

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *userMailVal = [defaults stringForKey:UD_MAIL];
    if (userMailVal == nil) userMailVal = @"your.email@address.com";
    [_email setStringValue:userMailVal];

    NSString *regCodeVal = [defaults stringForKey:UD_REGCODE];
    if (regCodeVal == nil) regCodeVal = @"please copy the license key you received by mail and paste it here";
    [_licensecode setStringValue:regCodeVal];

    BOOL ok = [self vaBene:userMailVal license:regCodeVal];
    if( ok ) {
        [_message setStringValue:@"This copy of PDFiler is fully licensed and active. Your email address and license key appear below.\nWe really appreciate your support!"];
        [_unlockButton setHidden:YES];
        [_buyButton setHidden:YES];
        [_cancelButton setHidden:YES];
        [_email setEnabled:NO];
        [_licensecode setEnabled:NO];
    } else {
        [_message setStringValue:@"This copy of PDFiler is in demo mode. It is fully functional, but inserts the word DEMO in every filename it processes."];
    }
}


- (IBAction)unlock:(id)sender {
    NSString *userMailVal = [_email stringValue];
    NSString *regCodeVal = [_licensecode stringValue];
    BOOL ok = [self vaBene:userMailVal license:regCodeVal];
    if( ok ) {
        [[NSUserDefaults standardUserDefaults] setObject:userMailVal forKey:UD_MAIL];
        [[NSUserDefaults standardUserDefaults] setObject:regCodeVal forKey:UD_REGCODE];
        [[NSUserDefaults standardUserDefaults] setObject:@"masi" forKey:UD_VABENE];
        [self close];
        NSRunAlertPanel(@"PDFiler unlocked!",
                        @"Thank you very much for supporting this app",
                        @"OK", nil, nil);
    } else {
        [_message setStringValue:@"Please enter the right license code"];
    }
}


-(BOOL) vaBene: (NSString *)email license: (NSString *)code {
    BOOL res = NO;
    unsigned long int len = [code length];
    jsmDebug(@"%@ %@ %lu", email, code, len);

    if ( len > 80 ) {
        NSString *sha = [self sha1:email];
        len = [sha length];
        jsmDebug(@"%lu ? %@", len, sha);

        NSString *mycode = [code substringWithRange: NSMakeRange (40, len)];
        jsmDebug(@"%@ ? %@", mycode, sha);

        if ([mycode isEqualToString:sha] ) {
            res = YES;
        }

    } else if ( [email isEqualToString:@"zenzi!"] ) { // nur zum testen - muss am ende raus!
        res = YES;
    }
    return res;
}


- (NSString *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    int len = (int) strlen(cStr);
    CC_SHA1(cStr, len, result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4], result[5], result[6],
                   result[7], result[8], result[9], result[10], result[11], result[12], result[13],
                   result[14], result[15], result[16], result[17], result[18], result[19]
                   ];
    return s;
}

- (IBAction)cancel:(id)sender {
    [self close];
}

- (IBAction)buy:(id)sender {
    NSURL *my_URL = [NSURL URLWithString:@"http://www.pdfiler.de/buy.html"];// ~buy-license/from-app an die url anhängen für eigene landing page!
    [[NSWorkspace sharedWorkspace] openURL: my_URL ];
}


@end

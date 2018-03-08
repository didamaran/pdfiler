//
//  pdfdatei.m
//
//  Created by Tom Nakat on 03.04.13.
//  Copyright (c) 2013 zenziware. All rights reserved.
//

#import "pdfdatei.h"
#import "Constants.h"

@implementation pdfdatei

- (id)init
{
    self = [super init];
    if (self) {
        _status          = [[NSMutableString alloc] initWithString:@"neu"];
        _targetName      = [[NSMutableString alloc] init];
        _status          = [[NSMutableString alloc] init];
        _icon            = nil;
        _fileSize		 = 0;
        _targetIndex	 = 0;
        _input_year      = @"";
        _input_mon       = @"";
        _input_day       = @"";
        _input_t1        = @"";
        _input_t2        = @"";
        _input_t3        = @"";
        _input_t4        = @"";
    }
    return self;
}


-(void) setNameWithDate: (NSArray *)dateParts andText: (NSArray *) textParts keyNum: (NSUInteger) ruleBase
{
    NSString *datum = [self makeDate:dateParts];
    _targetName = [self makeName:datum text:textParts];
    _ruleKey = [self makeRuleKey:textParts keyNum:ruleBase];
    _icon = [NSImage imageNamed:PFEIL_W];
    _status = @"named";

    // damit die einzelteile des gesamtnamens wieder in die richtigen inputfelder geschrieben werden können
    // wenn man noch was korrigieren will ...
    _input_year = [dateParts objectAtIndex:0];
    _input_mon  = [dateParts objectAtIndex:1];
    _input_day  = [dateParts objectAtIndex:2];
    _input_t1   = [textParts objectAtIndex:0];
    _input_t2   = [textParts objectAtIndex:1];
    _input_t3   = [textParts objectAtIndex:2];
    _input_t4   = [textParts objectAtIndex:3];

    /*----------------------------------------------------
     diverse checks, die sich auf den status auswirken können
     -----------------------------------------------------*/

    // wenn das pdf auch schon einem targetfolder zugeordnet wurde
    // (kann ja sein, dass man einen targetnamen doch noch mal ändert)
    if ( _targetPath == (id)[NSNull null] || _targetPath.length == 0 ) {
        _icon = [NSImage imageNamed:ACHTUNG_W];
        _status = @"no target path";
    } else if ( [self isNotEmpty:_targetFolder] ) {
        _icon = [NSImage imageNamed:PFEIL_B];
        _status = @"ready";
    }

    // gibt es am zielort aber schon ein pdf mit dem target-namen?
    if ([self fileAlreadyExists:_fullTargetPath])
    {
        _icon = [NSImage imageNamed:ACHTUNG_W];
        _status = @"file exists";
    }

 
    // ist der pfad überhaupt ok?
    // vielleicht haben sich ja folder-namen geändert oder wurden gelöscht
    /*
     if ( [fm alreadyExists:_targetName inFolder:targetFolder] ) {
     _icon = [NSImage imageNamed:@"achtung"];
     _status = @"path corrupt";
     if (isDir) {
     NSLog(@"Folder already exists...");
     }
     jsmDebug(@"%@ pfad ist kaputt!", _targetFolder);
     }
     */
}



-(void) setTarget: (NSString *)path
        targetRow: (NSUInteger)row
           byRule: (BOOL)reruled {
    _targetPath = path;
    _fullTargetPath = [NSString stringWithFormat:@"%@/%@.pdf", path, _targetName];
    _targetFolder = [path lastPathComponent];
    _targetIndex = row;
    if ( reruled )
    {
        _status = @"reruled";
        _icon = [NSImage imageNamed:RERULED];
    } else {
        _status = @"path set";
        _icon = [NSImage imageNamed:PFEIL_B];
    }

    // gibt es am zielort schon ein pdf mit dem target-namen?
    if ([self fileAlreadyExists:_fullTargetPath])
    {
        _icon = [NSImage imageNamed:ACHTUNG_W];
        _status = @"file exists";
    }
}


-(void) setState: (int)statusKonstante {
    switch (statusKonstante) {
        case PDF_NAME_EXISTS:
            _icon = [NSImage imageNamed:ACHTUNG_W];
            _status = @"name exists";
            break;

        case PDF_RENAMED:
            _icon = [NSImage imageNamed:PFEIL_W];
            _status = @"renamed";
            break;

        case NO_TARGET:
            _icon = [NSImage imageNamed:CIRCLE_B];
            _status = @"no target";
            break;

        default:
            _icon = [NSImage imageNamed:ACHTUNG_W];
            _status = @"n/a";
            break;
    }
}




#pragma mark -
#pragma utilities

- (BOOL)fileAlreadyExists:(NSString *) path // http://stackoverflow.com/questions/3436173/nsstring-is-empty
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL exists = NO;
    BOOL isDir;
    BOOL fileExists = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (fileExists)
    {
        exists = YES;
    }
    return exists;
}




// das datum aus den drei datums-inputs zusammensetzen
- (NSString *)makeDate: (NSArray *)datumsTeile
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *filteredDatumsTeile = [datumsTeile filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    return [filteredDatumsTeile componentsJoinedByString:[standardDefaults stringForKey:PREF_SEPARATOR]];
}


// aus dem bereits erstellten datum und den text-inputs den finalen namen zusammensetzen
- (NSString *)makeName: (NSString *)datum text: (NSArray *) textParts
{
    NSArray *textTeile = @[ datum, [textParts objectAtIndex:0], [textParts objectAtIndex:1], [textParts objectAtIndex:2], [textParts objectAtIndex:3] ];
    NSArray *filteredTextTeile = [textTeile filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    NSString *concatenatedString = [filteredTextTeile componentsJoinedByString:@" "];
    return [concatenatedString stringByReplacingOccurrencesOfString:@"/" withString:@""];// im pfad darf kein slash enthalten sein
}


- (NSString *)makeRuleKey: (NSArray *) textParts keyNum: (NSUInteger) ruleBaseNum
{
    if(ruleBaseNum > 0) {
        NSMutableArray * textTeile = [[NSMutableArray alloc] init];
        int i;
        for (i=0; i < 3; i++) {
            if( i < ruleBaseNum ) { [textTeile addObject:[textParts objectAtIndex:i]]; }
        }
        NSArray *filteredTextTeile = [textTeile filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        return [filteredTextTeile componentsJoinedByString:@" "];
    } else {
        return @"";
    }
}




- (BOOL)isNotEmpty:(NSString *)string // http://stackoverflow.com/questions/3436173/nsstring-is-empty
{
    if (((NSNull *) string == [NSNull null]) || (string == nil) ) {
        return NO;
    }
    string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Note that [string length] == 0 can be false when [string isEqualToString:@""] is true, because these are Unicode strings.
    if ([string isEqualToString:@""]) {
        return NO;
    }
    if ( [string length] == 0 ) {
        return NO;
    }

    return YES;
}



-(void) setDemoName
{
    if( [self isNotEmpty:self.targetName] ) {
        NSString *demoName = [[NSString alloc] initWithFormat:@"DEMO %@", self.targetName];
        self.targetName = demoName;
        self.fullTargetPath = [NSString stringWithFormat:@"%@/%@.pdf", self.targetPath, self.targetName];
    }
}


-(NSString *) description {
    return [NSString stringWithFormat:@"\n++++++++++++++++++++++++++\nicon: %@\nrulekey: %@\nstatus: %@\ntargetIndex: %lu\ntargetname: %@\ntargetfolder: %@\ntargetPath: %@\nfullSourcePath: %@\nfullTargetPath: %@\n++++++++++++++++++++++++++\n\n",
            _icon, _ruleKey, _status, _targetIndex, _targetName,
            _targetFolder, _targetPath, _fullSourcePath, _fullTargetPath];
}

@end

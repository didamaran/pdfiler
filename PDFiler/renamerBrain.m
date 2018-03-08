//
//  renamerBrain.m
//  PDFiler
//
//  Created by Tom Nakat on 28.08.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "Constants.h"
#import "renamerBrain.h"
#import "targetFolder.h"
#import "pdfdatei.h"

@implementation renamerBrain

static NSUInteger           ruleBase = 1;
static NSMutableString      *currentTarget;
static NSMutableString      *currentMandant;
static NSUInteger           currentTargetRow = 0;
static NSString             *appSupportDir;
static NSMutableDictionary  *regeln;


- (id)init
{
    self = [super init];
    if (self) {
        _mode = YES;
        _files = [[NSMutableArray alloc] init];
        _folders = [[NSMutableArray alloc] init];
        currentTarget = [[NSMutableString alloc] init];
        currentMandant = [[NSMutableString alloc] init];
    }
    return self;
}




#pragma mark -
#pragma mark basix


-(pdfdatei *) getpdf: (NSInteger) i {
    if ( [_files count] > 0 ) {
        return [_files objectAtIndex:i];
    } else {
        pdfdatei *pdf = [[pdfdatei alloc] init];
        return pdf;
    }
}

-(targetFolder *) gettarget: (NSInteger) i {
    if ( [_folders count] > 0 ) {
        return [_folders objectAtIndex:i];
    } else {
        targetFolder *folder = [[targetFolder alloc] init];
        return folder;
    }
}

-(NSInteger) getCountOfPdfs {
    return [_files count];
}

-(NSInteger) getCountOfFolders {
    return [_folders count];
}


-(void) setTargetPath: (NSUInteger) rowOfTargets {
    targetFolder *t = [_folders objectAtIndex:rowOfTargets];
    currentTarget = [NSMutableString stringWithString:t.fullPath];
    currentTargetRow = rowOfTargets;
}

-(NSString *) getCurrentTargetPath {
    return currentTarget;
}

-(NSString *) getMandant {
    return currentMandant;
}

-(NSMutableArray *) getRuleArray: (NSUInteger) i {
    switch (i)
    {
        case 1:
            return _ruleWords_1;
            break;
        case 2:
            return _ruleWords_2;
            break;
        case 3:
            return _ruleWords_3;
            break;
        case 4:
            return _ruleWords_4;
            break;
        default:
            return _ruleWords_1;
            break;
    }
}

-(NSInteger) getCountOfRules {
    return [_rules count];
}


/*
-(void) deleteRule: (NSString *) key {
    if ( key != nil ) {
        NSString *path = [[NSString alloc] initWithString:[_rules objectForKey:key]];
        jsmDebug(@"%@ = %@", key, path);
        [_rules removeObjectForKey:key];
    }
    jsmDebug(@"rules count = %lu", [_rules count]);
}
*/


-(NSMutableDictionary *) getRegeln {
    return regeln;
}




#pragma mark -
#pragma mark filemanagement


-(void) setMandant: (NSString*) man
{
    currentMandant = [NSMutableString stringWithString:man];
    [[NSUserDefaults standardUserDefaults] setObject:man
                                              forKey:PREF_MAN];
}

- (void) loadMandant
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ( [currentMandant isEqualToString:@""] ) {
        appSupportDir = [NSString stringWithFormat:@"%@/PDFiler", [paths objectAtIndex:0]];
    } else {
        appSupportDir = [NSString stringWithFormat:@"%@/PDFiler/%@", [paths objectAtIndex:0], currentMandant];
    }
    NSError *error = nil;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:appSupportDir];
    if ( !fh ) {
        [fm createDirectoryAtPath:appSupportDir withIntermediateDirectories:YES attributes:nil error:&error];
    }


    /*----------------------------------------------------
     // das rules-dictionary aus dem entsprechenden file laden bzw.
     // ein solches file erstellen, wenn noch keines vorhanden ist
     -----------------------------------------------------*/
    NSString *rulesPath = [NSString stringWithFormat:@"%@/rules.plist", appSupportDir];
    if( [fm fileExistsAtPath: rulesPath ] ) {
        _rules = [[NSMutableDictionary alloc] initWithContentsOfFile:rulesPath];
    } else {
        _rules = [[NSMutableDictionary alloc] init];
        [_rules writeToFile:rulesPath
                 atomically:YES];
    }
    regeln = [_rules copy]; // ist das eine klassenvariable?


    /*----------------------------------------------------
     // das gleiche für die mandantenspezifischen prefs
     -----------------------------------------------------*/
    if( [BTARGET isEqualToString:@"HN"] || [BTARGET isEqualToString:@"DPA"] ) {
        NSString *prefsPath = [NSString stringWithFormat:@"%@/prefs.plist", appSupportDir];
        if( [fm fileExistsAtPath: prefsPath ] ) {
            _mprefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
            // die mandantenspezifischen prefs in die NSUserdefaults schreiben
            [ud setObject:[_mprefs objectForKey:PREF_SEPARATOR] forKey:PREF_SEPARATOR];
            [ud setObject:[_mprefs objectForKey:PREF_SOURCE] forKey:PREF_SOURCE];
            [ud setObject:[_mprefs objectForKey:PREF_TARGET] forKey:PREF_TARGET];
        } else {
            _mprefs = [[NSMutableDictionary alloc] init];
            [_mprefs writeToFile:prefsPath
                      atomically:YES];
        }
    }


    /*----------------------------------------------------
     sourcefolder + targetfolder aus den prefs holen bzw.
     wenn noch keine prefs vorhanden sind, den folder
     ~/User/Documents als Standardfolder hernehmen
     -----------------------------------------------------*/
    NSString *sourcePathVal = [ud stringForKey:PREF_SOURCE];
    if(sourcePathVal != nil) {
        NSURL* url = [[NSURL alloc] initFileURLWithPath:sourcePathVal];
        [self loadPdfsFromFolder:url];
    }

    NSString *targetPathVal = [ud stringForKey:PREF_TARGET];
    if(targetPathVal != nil) {
        NSURL* url2 = [[NSURL alloc] initFileURLWithPath:targetPathVal];
        [self loadTargetFolders:url2];
    }
    
    /*----------------------------------------------------
     die autocompletion-data laden
     -----------------------------------------------------*/
    NSMutableString *autoPath = [NSString stringWithFormat:@"%@/auto1.plist", appSupportDir];
    //jsmDebug(@"rules auto %@", autoPath);
    if( [fm fileExistsAtPath: autoPath ] ) {
        _ruleWords_1 = [[NSMutableArray alloc] initWithContentsOfFile:autoPath];
    } else {
        _ruleWords_1 = [[NSMutableArray alloc] init];
        [_ruleWords_1 writeToFile:autoPath atomically:YES];
    }
    autoPath = [NSString stringWithFormat:@"%@/auto2.plist", appSupportDir];
    if( [fm fileExistsAtPath: autoPath ] ) {
        _ruleWords_2 = [[NSMutableArray alloc] initWithContentsOfFile:autoPath];
    } else {
        _ruleWords_2 = [[NSMutableArray alloc] init];
        [_ruleWords_2 writeToFile:autoPath atomically:YES];
    }
    autoPath = [NSString stringWithFormat:@"%@/auto3.plist", appSupportDir];
    if( [fm fileExistsAtPath: autoPath ] ) {
        _ruleWords_3 = [[NSMutableArray alloc] initWithContentsOfFile:autoPath];
    } else {
        _ruleWords_3 = [[NSMutableArray alloc] init];
        [_ruleWords_3 writeToFile:autoPath atomically:YES];
    }
    autoPath = [NSString stringWithFormat:@"%@/auto4.plist", appSupportDir];
    if( [fm fileExistsAtPath: autoPath ] ) {
        _ruleWords_4 = [[NSMutableArray alloc] initWithContentsOfFile:autoPath];
    } else {
        _ruleWords_4 = [[NSMutableArray alloc] init];
        [_ruleWords_4 writeToFile:autoPath atomically:YES];
    }
}



- (void) loadPdfsFromFolder: (NSURL *) url
{

    NSString *withPath = [[NSString alloc] init];
    withPath = [url path];
    //jsmDebug(@"%@", url);
    int count = 0;
    BOOL isDir;

    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:withPath isDirectory:&isDir] && isDir)
    {

        NSError *error = nil;
        NSArray *listOfFiles = [fm contentsOfDirectoryAtPath:withPath error:&error];

        if(error)
        {
            //jsmDebug(@"error in %@: %@", withPath, error);
        } else {
            // only select pdf-files
            // http://mobiledevelopertips.com/data-file-management/get-list-of-all-specified-files-types-png-xml-etc.html
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH[cd] '.pdf'"];
            NSArray *pdfFiles = [listOfFiles filteredArrayUsingPredicate:filter];

            [_files removeAllObjects];

            // for each item: create a pdf-object and add to _files-array
            for ( id fileitem in pdfFiles )
            {
                NSString *fullpath = [NSString stringWithFormat:@"%@/%@", withPath, fileitem];
                NSDictionary* fileInfos = [fm attributesOfItemAtPath: fullpath error: &error];
                pdfdatei * pdf = [[pdfdatei alloc] init];
                pdf.originalName = fileitem;
                pdf.targetName = fileitem;
                pdf.fullSourcePath = fullpath;
                pdf.fullTargetPath = fullpath;
                pdf.status = @"neu";
                pdf.creationDate = [fileInfos objectForKey:NSFileCreationDate];
                pdf.modificationDate = [fileInfos objectForKey:NSFileModificationDate];
                pdf.fileSize = fileInfos.fileSize;
                pdf.myIndex = count;
                [_files addObject:pdf];
                count++;
                //jsmDebug(@"%@", pdf);
            }
            // und _files jetzt noch nach dateinamen sortieren
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"originalName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [_files sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
    } else {
        //jsmDebug(@"%@ enthält keine PDFs", withPath);
    }
}



-(void)loadTargetFolders:(NSURL *)insideOfUrl
{
    NSString *path = [[NSString alloc] init];
    path = [insideOfUrl path];
    BOOL isDir;

    NSFileManager *fm=[[NSFileManager alloc] init];
    //jsmDebug(@"%@", path);

    if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir)
    {

        // Enumerate the directory
        // Request the two properties the method uses, name and isDirectory
        // Ignore hidden files
        // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
        NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:insideOfUrl
                                        includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, NSURLIsPackageKey, nil]
                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                      errorHandler:nil];

        [_folders removeAllObjects];
        NSUInteger i = 0;

        targetFolder *rt = [[targetFolder alloc] initWithUrl: insideOfUrl andIndex: i resetDepth:YES];
        [_folders addObject:rt];

        // Enumerate the dirEnumerator results, each value is stored in allURLs
        for (NSURL *theURL in dirEnumerator) {

            // Retrieve whether a directory
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

            // Retrieve whether a package
            NSNumber *isPackage;
            [theURL getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];

            // Add full path for directories
            if ( [isDirectory boolValue] == YES && [isPackage boolValue] == NO ) {
                i++;
                targetFolder *t = [[targetFolder alloc] initWithUrl: theURL andIndex: i resetDepth:NO];
                [_folders addObject:t];
            }
        }
    }
}



-(BOOL) makeSubfolder: (NSUInteger) row
{
    targetFolder *target = [[targetFolder alloc] init];
    target = [_folders objectAtIndex:row];
    NSString *folderPath = [NSString stringWithFormat:@"%@%@", [target.url path], @"/test"];
    //jsmDebug(@"%@", folderPath);
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    [localFileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    return YES;
}







#pragma mark -
#pragma mark pdfs verarbeiten

-(NSString *) getTargetPathForKey: (NSString *) key {
    return [_rules objectForKey:key];
}

-(void) overrideTargetofSourceRow: (NSInteger) i
                    withTargetRow: (NSInteger) t
                     changingRule: (BOOL) b {

    pdfdatei *alt_pdf = [self getpdf:i];
    targetFolder *f = [_folders objectAtIndex:t];
    currentTarget =(NSMutableString*) f.fullPath;

    pdfdatei * neu_pdf = [[pdfdatei alloc] init];
    neu_pdf.originalName    = alt_pdf.originalName;
    neu_pdf.targetName      = alt_pdf.targetName;
    neu_pdf.fullTargetPath  = [NSString stringWithFormat:@"%@/%@.pdf", currentTarget, alt_pdf.targetName];
    neu_pdf.targetPath      = currentTarget;
    neu_pdf.targetIndex     = t;
    neu_pdf.fullSourcePath  = alt_pdf.fullSourcePath;
    neu_pdf.status          = @"overridden";
    neu_pdf.creationDate    = alt_pdf.creationDate;
    neu_pdf.modificationDate = alt_pdf.modificationDate;
    neu_pdf.fileSize        = alt_pdf.fileSize;
    neu_pdf.myIndex         = alt_pdf.myIndex;
    neu_pdf.ruleKey         = alt_pdf.ruleKey;
    neu_pdf.icon            = [NSImage imageNamed:PFEIL_B];
    neu_pdf.targetFolder    = [currentTarget lastPathComponent];
    [_files replaceObjectAtIndex:i withObject:neu_pdf];

    if ( b ) {
        [_rules removeObjectForKey:neu_pdf.ruleKey];
        [_rules setObject:currentTarget forKey:neu_pdf.ruleKey];
    }
    jsmDebug(@"%lu / %lu: %@\nforKey:%@", i,t, currentTarget, neu_pdf.ruleKey);
}


-(void) composePdfName: (NSArray *)dateParts
               andText: (NSArray *) textParts
           ofSourceRow: (NSInteger) i
         withTargetRow: (NSInteger) t {

    if([self getCountOfPdfs] > 0) {

        // inputs an das pdf übergeben, das dann selber alle seine properties setzt
        pdfdatei *pdf = [self getpdf:i];
        [pdf setNameWithDate:dateParts andText:textParts keyNum:ruleBase];
        pdf.targetIndex = t;

        if ( _mode && [self getCountOfFolders] > 0 ) // datei soll auch verschoben werden, also regel checken und evtl neu anlegen, aber nur, wenn auch targetfolders vorhanden sind!
        {
            //erstmal davon ausgehen, dass noch keine regel vorhanden ist
            targetFolder *f = [_folders objectAtIndex:t];
            jsmDebug(@"%lu / %lu: %@", i,t, f.fullPath);
            [pdf setTarget:f.fullPath targetRow:t byRule:NO];

            // gibt es für den neuen namen schon eine regel?
            NSString *ruleBasedTargetPath = [_rules objectForKey:pdf.ruleKey];
            if ( [pdf isNotEmpty:ruleBasedTargetPath] ) {
                [pdf setTarget:ruleBasedTargetPath targetRow:i byRule:YES];
            } else {
                [_rules setObject:currentTarget forKey:pdf.ruleKey];
            }

            // gibt es schon eine datei im aktuellen set mit dem gleichen namen im gleichen target folder?
            for(pdfdatei *f in self.files) {
                if ( [f.targetName isEqualToString:pdf.targetName] && [f.targetFolder isEqualToString:pdf.targetFolder] && f.myIndex != pdf.myIndex ) {
                    [pdf setState:PDF_NAME_EXISTS];
                }
            }

        } else if ( [self getCountOfFolders] > 0 ) {
            [pdf setState:PDF_RENAMED];
        } else {
            [pdf setState:NO_TARGET];
        }

        // am ende das upgedatete pdf wieder in das files-array einsetzen
        [_files replaceObjectAtIndex:i withObject:pdf];

        // auto-complete arrays updaten
        NSMutableString *partString = [textParts objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", partString];
        NSArray *results = [_ruleWords_1 filteredArrayUsingPredicate:predicate];
        if ( [results count] == 0 ) { [_ruleWords_1 addObject:partString]; }

        partString = [textParts objectAtIndex:1];
        predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", partString];
        results = [_ruleWords_2 filteredArrayUsingPredicate:predicate];
        if ( [results count] == 0 ) { [_ruleWords_2 addObject:partString]; }

        partString = [textParts objectAtIndex:2];
        predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", partString];
        results = [_ruleWords_3 filteredArrayUsingPredicate:predicate];
        if ( [results count] == 0 ) { [_ruleWords_3 addObject:partString]; }

        partString = [textParts objectAtIndex:3];
        predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", partString];
        results = [_ruleWords_4 filteredArrayUsingPredicate:predicate];
        if ( [results count] == 0 ) { [_ruleWords_4 addObject:partString]; }

    }
}



- (void) processFiles
{
    // DEMO oder REGISTERED?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *demoOrNot = [defaults stringForKey:UD_VABENE];

    NSFileManager *fm = [[NSFileManager alloc] init];

    // Text für das Logfile initialisieren (u.a. mit zeitstempel beginnen)
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.LL.yyyy HH:mm"];
    NSMutableString *loglines= [[NSMutableString alloc]init];
    [loglines appendString: [NSString stringWithFormat:@"%@\r\n", [dateFormatter stringFromDate:now]]];
    [loglines appendString: @"------------------------------------------------------\r\n"];

    // dateien verarbeiten und log schreiben
    int i;
    int num = (int)[_files count]; // casting muss sein, weil count unsigned int zurückgibt, was wiederum zu einem fehler in der for-loop führt, weil i>=0 dann immer wahr ist! (strange...)
    NSMutableArray *remainingFiles = [[NSMutableArray alloc] init];
    NSMutableString *ziel = [[NSMutableString alloc] init];

    for (i=0; i < num; i++)
    {
        pdfdatei *pdf = [_files objectAtIndex:i];

        // falls noch im demo modus, den targetnamen entsprechend umbenennen
        if (![demoOrNot isEqual: @"masi"]) {
            [pdf setDemoName];
        }

        // nur wenn das pdf überhaupt bearbeitet wurde
        if ( ![pdf.originalName isEqualToString:pdf.targetName] || ![pdf.fullSourcePath isEqualToString:pdf.fullTargetPath] )
        {

            BOOL r = NO;
            if( pdf.fullTargetPath == nil || [fm fileExistsAtPath: pdf.fullTargetPath ] == YES  || ![fm fileExistsAtPath: pdf.fullSourcePath ] ) {
                r = NO;
            } else {

                if ( _mode ) // datei verschieben
                {
                    ziel = [NSMutableString stringWithString: pdf.fullTargetPath];
                } else { // datei nur umbenennen
                    ziel = [NSMutableString stringWithFormat:@"%@/%@.pdf", [pdf.fullSourcePath stringByDeletingLastPathComponent], pdf.targetName];
                    //jsmDebug(@"%@", ziel);
                }

                NSError *error = nil;
                [fm moveItemAtPath:pdf.fullSourcePath
                            toPath:ziel
                             error:&error];
                if(!error) {
                    r = YES;
                } else {
                    r = NO;
                }
            }

            if (r) {
                pdf.icon = [NSImage imageNamed:FASTFORWARD];
                pdf.status = @"moved";
                [loglines appendString: [NSString stringWithFormat:@"%@ \n--> %@ \r\n", pdf.originalName, ziel]];
                if ([fm fileExistsAtPath: pdf.fullSourcePath]) {
                    [fm removeItemAtPath:pdf.fullSourcePath error:NULL];
                }
            } else {
                pdf.icon = [NSImage imageNamed:ACHTUNG_B];
                [loglines appendString: [NSString stringWithFormat:@"%@ \n#!# %@ could not be processed\r\n", pdf.originalName, ziel]];
                [remainingFiles addObject:pdf];
            }
        } else {
            //[loglines appendString: [NSString stringWithFormat:@"%i: %@ \n# %@ was not fully defined(%@)\r\n", i, pdf.originalName, ziel, pdf.status]];
            [remainingFiles addObject:pdf];
        }
    }

    [_files removeAllObjects];
    [_files addObjectsFromArray:remainingFiles];

    // now write log-string to file
    [loglines appendString: @"------------------------------------------------------\r\n"];
    NSInteger diff = num - [_files count];
    [loglines appendString: [NSString stringWithFormat:@"processed %lu PDFs", diff]];

    NSError *err;
    NSString *path = [NSString stringWithFormat:@"%@/log.txt", appSupportDir];
    jsmDebug(@"%@\n%@", path, loglines);
    [loglines writeToFile:path
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&err];

    // das aktuelle ruleset aud die autocompletes sichern
    path = [NSString stringWithFormat:@"%@/rules.plist", appSupportDir];
    [_rules writeToFile:path atomically:YES];
    path = [NSString stringWithFormat:@"%@/auto1.plist", appSupportDir];
    [_ruleWords_1 writeToFile:path atomically:YES];
    path = [NSString stringWithFormat:@"%@/auto2.plist", appSupportDir];
    [_ruleWords_2 writeToFile:path atomically:YES];
    path = [NSString stringWithFormat:@"%@/auto3.plist", appSupportDir];
    [_ruleWords_3 writeToFile:path atomically:YES];
    path = [NSString stringWithFormat:@"%@/auto4.plist", appSupportDir];
    [_ruleWords_4 writeToFile:path atomically:YES];

}


-(void) setRuleBaseNum: (NSUInteger) n {
    ruleBase = n;
}


-(void) switchMode {
    if ( _mode ) {
        _mode = NO;
    } else {
        _mode = YES;
    }
}

@end

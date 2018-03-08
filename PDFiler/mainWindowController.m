//
//  mainWindowController.m
//  PDFiler
//
//  Created by Tom Nakat on 12.07.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "mainWindowController.h"
#import "renamerBrain.h"
#import "targetFolder.h"
#import "pdfdatei.h"
#import "Constants.h"


@implementation mainWindowController

static NSUInteger currentSourceRow = 0;
static NSUInteger currentTargetRow = 0;



- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _brain = [[renamerBrain alloc] init];
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud addObserver:self
         forKeyPath:UD_VABENE
            options:NSKeyValueObservingOptionNew
            context:NULL];

    return self;
}




// KVO handler: http://stackoverflow.com/questions/15202562/detect-changes-on-nsuserdefaults
// und http://stackoverflow.com/questions/10871860/nsuserdefaultsdidchangenotification-whats-the-name-of-the-key-that-changed
// brauchts für änderungen am dateglue und beim freischalten
// UD_VABENE      = @"vabene"

-(void)observeValueForKeyPath:(NSString *)aKeyPath
                     ofObject:(id)anObject
                       change:(NSDictionary *)aChange
                      context:(void *)aContext
{
    NSString *val = [aChange valueForKey:@"new"];
    jsmDebug(@"Defaults changed, %@ = %@", aKeyPath, val);
    if ( [aKeyPath isEqualToString:UD_VABENE] && [val isEqualToString:@"masi"]) {
        [self.window setTitle:@"PDFiler"];
    }
}




- (void)awakeFromNib
{
    // option Mandant wechseln aus dem Menu entfernen (bei der kleinen version…)
    if( ![BTARGET isEqualToString:@"HN"] && ![BTARGET isEqualToString:@"DPA"] ) {
        NSMenu *mainMenu = [NSApp mainMenu];
        for (NSMenuItem* subMenu in mainMenu.itemArray)
        {
            if ([subMenu.title isEqualToString:@"Rename"])
            {
                NSArray *array = subMenu.submenu.itemArray;
                [subMenu.submenu removeItem:[array objectAtIndex:3]]; // make subfolder
                [subMenu.submenu removeItem:[array objectAtIndex:0]]; // mandanten wechseln
            }
        }
    }

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSNumber *jahr = [[NSNumber alloc] initWithLong:[components year]];

    NSNumberFormatter *numberFormatter1 = [[NSNumberFormatter alloc] init];
    [numberFormatter1 setPositiveFormat:@"####"];
    [numberFormatter1 setMaximum: jahr];

    [[_sfinputJahr cell] setSearchButtonCell:nil];
    [[_sfinputJahr cell] setCancelButtonCell:nil];
    [[_sfinputJahr cell] setFormatter:numberFormatter1];
    [_sfinputJahr setStringValue:[NSString stringWithFormat:@"%li", [components year]]];

    NSNumberFormatter *numberFormatter2 = [[NSNumberFormatter alloc] init];
    [numberFormatter2 setPositiveFormat:@"00"];
    [numberFormatter2 setMaximum: [NSNumber numberWithInt:12]];
    [[_sfinputMonat cell] setSearchButtonCell:nil];
    [[_sfinputMonat cell] setCancelButtonCell:nil];
    [[_sfinputMonat cell] setFormatter:numberFormatter2];
    [_sfinputMonat setStringValue:[NSString stringWithFormat:@"%02li", [components month]]];

    NSNumberFormatter *numberFormatter3 = [[NSNumberFormatter alloc] init];
    [numberFormatter3 setPositiveFormat:@"00"];
    [numberFormatter3 setMaximum: [NSNumber numberWithInt:31]];
    [[_sfinputTag cell] setSearchButtonCell:nil];
    [[_sfinputTag cell] setCancelButtonCell:nil];
    [[_sfinputTag cell] setFormatter:numberFormatter3];
    [_sfinputTag setStringValue:[NSString stringWithFormat:@"%02li", [components day]]];

    [[_sfinput1 cell] setSearchButtonCell:nil];
    [[_sfinput1 cell] setCancelButtonCell:nil];
    [[_sfinput2 cell] setSearchButtonCell:nil];
    [[_sfinput2 cell] setCancelButtonCell:nil];
    [[_sfinput3 cell] setSearchButtonCell:nil];
    [[_sfinput3 cell] setCancelButtonCell:nil];
    [[_sfinput4 cell] setSearchButtonCell:nil];
    [[_sfinput4 cell] setCancelButtonCell:nil];

    [self resetTextColors]; // im brain ist ruleBase zum start auf 1 gesetzt
    [_sfinput1 setTextColor:[NSColor blackColor]];
    [self.window makeFirstResponder:_sfinputMonat];
}


- (void)windowDidLoad
{
    [super windowDidLoad];

    /*----------------------------------------------------
     window-elemente vorbereiten
     -----------------------------------------------------*/
    [_targetTable setBackgroundColor:[NSColor clearColor]];
    [_sourceTable setBackgroundColor:[NSColor clearColor]];
    [_pdfview setBackgroundColor:[NSColor clearColor]];

    // http://stackoverflow.com/questions/7795505/nswindow-textured-background-with-nstextfield
    // set the content border thickness to 0 for both the top and bottom window edges
    [[super window] setContentBorderThickness:0 forEdge:NSMaxYEdge]; // top border
    [[super window] setContentBorderThickness:0 forEdge:NSMinYEdge]; // bottom border

    // disable the auto-recalculation of the window's content border
    [[super window] setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];
    [[super window] setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
//    NSColor *c = [NSColor colorWithCalibratedRed:0.227f green:0.251f blue:0.337 alpha:1];
//    [[super window] setBackgroundColor:c]; // das färbt den titelbalken auch mit ein!


    if( [BTARGET isEqualToString:@"HN"] || [BTARGET isEqualToString:@"DPA"] ) {
        [self chooseMandant];
    } else {
        // DEMO oder REGISTERED?
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *demoOrNot = [defaults stringForKey:UD_VABENE];
        if (![demoOrNot isEqual: @"masi"]) {
            [self.window setTitle:@"PDFiler    * DEMO *"];
        }
        [self loadMandant];
    }

    [self.window makeFirstResponder:_sfinput1];

}




-(BOOL) windowShouldClose:(NSNotification *)notification {
    BOOL r = YES;
    if(_hasModifiedNames) {
        NSInteger res = NSRunAlertPanel(@"Do you really want to quit?",
                                        @"There are some files which haven't been processed yet!",
                                        @"cancel", @"quit", nil);
        if(res == 0) {
            r = YES; // quit anyway
        } else {
            r = NO;
        }
    }
    return r;
}



- (BOOL)loadMandant
{
    [_mandantenAuswahlDefaultButton setKeyEquivalent:@"\r"];
    [_mandantenAuswahlWindow setDefaultButtonCell:[_mandantenAuswahlDefaultButton cell]];
    NSRect frame = [self.window frame];
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;
    [mainview addSubview:progressBox];
    [progressBox setFrame:NSMakeRect(0,0,width,height)];
    [spinningWheel startAnimation:self];


    [_brain loadMandant];
    [self setSelectedRowOfTable:_sourceTable toRow:0];
    [self setSelectedRowOfTable:_targetTable toRow:0];
    [_sourceTable reloadData];
    [_targetTable reloadData];
    [self badge];
    currentSourceRow = 0;
    currentTargetRow = 0;

    [progressBox removeFromSuperview];

    NSDockTile *dockTile = [NSApp dockTile];
    if([_brain.files count] > 0) {
        [dockTile setBadgeLabel:[NSString stringWithFormat:@"%li", [_brain.files count]]];
    } else {
        [dockTile setBadgeLabel:nil];
        //        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"pdf"];
        //        NSURL* url = [NSURL fileURLWithPath:filePath];
        //        PDFDocument *document = [[PDFDocument alloc] initWithURL: url];
        //        self.pdfviewer.document = document;
        jsmDebug(@"keine files im source vorhanden");
    }

    return YES;
}


- (void)chooseMandant {
    if( [BTARGET isEqualToString:@"HN"] )
    {
        [NSApp beginSheet: switchTomHnSheet
           modalForWindow: self.window
            modalDelegate: self
           didEndSelector: NULL
              contextInfo: NULL];
    } else {
        [NSApp beginSheet: selectMandantSheet
           modalForWindow: self.window
            modalDelegate: self
           didEndSelector: NULL
              contextInfo: NULL];
    }
}




#pragma mark -
#pragma mark IB Actions

- (IBAction)changeMandant:(id)sender {
    [self chooseMandant];
}


- (IBAction)selectMandant:(id)sender {
    // sheet entfernen
    [NSApp endSheet:selectMandantSheet];
    [selectMandantSheet orderOut:sender];

    // die ausgewählte mandanten-id holen
    NSString *mandantenID = [_mandant2load stringValue];
    jsmDebug(@"%@", mandantenID);

    NSAlert *alert = [[NSAlert alloc] init];

    // wenn currentMandant UND mandanten-id leer sind, gleich nochmal anfordern
    if( [mandantenID isEqualToString:@""] && [_currentMandant isEqualToString:@""] ) {
        [alert setMessageText:@"es muss ein Mandant ausgewählt werden!"];
        [alert runModal];
        [self chooseMandant];
        // wenn currentMandant schon einen wert hatte und mandanten-id leer ist, wird nichts geändert
    } else if( [mandantenID isEqualToString:@""] ) {
        jsmDebug(@"der Mandant wird nicht gewechsel");
        // currentMandant UND mandanten-id haben einen wert, also wird von einem zum anderen gewechselt
    } else {
        _currentMandant = mandantenID;
        [self.window setTitle:[NSString stringWithFormat:@"PDFiler > %@", _currentMandant]];
        if( [self loadMandant] ) {
            [alert setMessageText: [NSString stringWithFormat:@"Mandant %@ geladen", _currentMandant]];
            [alert runModal];
        } else {
            [alert setMessageText:@"Mandant konnte nicht geladen werden!"];
            [alert runModal];
            [self chooseMandant];
        }
    }
}


- (IBAction)cancelSelectMandant:(id)sender {
    [NSApp endSheet:selectMandantSheet];
    [selectMandantSheet orderOut:sender];
    NSAlert *alert = [[NSAlert alloc] init];
    if( [_currentMandant isEqualToString:@""] ) {
        [alert setMessageText:@"es muss ein Mandant ausgewählt werden!"];
        [alert runModal];
        [self chooseMandant];
    }
}


- (IBAction)selectHN:(id)sender {
    [NSApp endSheet:switchTomHnSheet];
    [switchTomHnSheet orderOut:sender];
    _currentMandant = @"HN";
    [_brain setMandant:_currentMandant];
    [self.window setTitle:@"PDFiler > H&N"];
    [self loadMandant];
    [self.window makeFirstResponder:_sfinput1];
}

- (IBAction)selectTom:(id)sender {
    [NSApp endSheet:switchTomHnSheet];
    [switchTomHnSheet orderOut:sender];
    _currentMandant = @"tom";
    [_brain setMandant:_currentMandant];
    [self.window setTitle:@"PDFiler > tom"];
    [self loadMandant];
    [self.window makeFirstResponder:_sfinput1];
}



- (IBAction)sourceClicked:(id)sender {
    currentSourceRow = [_sourceTable selectedRow];
    [self.window makeFirstResponder:_sfinput1];
}

- (IBAction)targetClicked:(id)sender {
    BOOL r = [self checkForRule];
    if(r) {
        [_brain setTargetPath:currentTargetRow];
        [self nextSourceRow:self];
//    } else {
//        [self setSelectedRowOfTable:_targetTable toRow:currentTargetRow];
    }
    [self.window makeFirstResponder:_sfinput1];
}



- (BOOL) checkForRule {
    // wenn das aktuelle pdf schon über eine regel zugeordnet ist
    // dann checken und nachfragen, ob die regel geändert werden soll
    pdfdatei *pdf = [_brain.files objectAtIndex:currentSourceRow];
    if ( ![pdf.fullSourcePath isEqualToString:pdf.fullTargetPath] ) {
        NSInteger res = NSRunAlertPanel(@"Selected target is conflicting with a rule",
                                        @"According to a rule this file should go into another folder than the one you selected. Do you want to continue with the selcted target, and should the rule even be redfined with this target?",
                                        @"cancel", @"continue", @"redefine rule"); // abbrechen = 1, erhalten = 0, neu = undef!?

        if(res == NSAlertOtherReturn) { // regel neu definieren
            jsmDebug(@"regel neu definieren");
            [_brain overrideTargetofSourceRow:currentSourceRow withTargetRow:currentTargetRow changingRule:YES ];
            return YES;
        } else if (res == NSAlertAlternateReturn) { // ordner einfach nur einsetzen
            [_brain overrideTargetofSourceRow:currentSourceRow withTargetRow:currentTargetRow changingRule:NO ];
            return YES;
        } else {
            jsmDebug(@"abgebrochen");
            [self selectCorrespondingTargetRowForTargetPath:pdf.targetPath];
        }
    }
    return NO;
}



- (IBAction)go:(id)sender {

    [_brain processFiles];
    _hasModifiedNames = NO;
    [self loadMandant];
}



#pragma mark -
#pragma mark menu befehle

- (IBAction)setRulebaseNull:(id)sender {
    [_brain setRuleBaseNum: 0];
    [self resetTextColors];
}

- (IBAction)setRulebaseOne:(id)sender {
    [_brain setRuleBaseNum: 1];
    [self resetTextColors];
    [_sfinput1 setTextColor:[NSColor blackColor]];
}

- (IBAction)setRulebaseTwo:(id)sender {
    [_brain setRuleBaseNum: 2];
    [self resetTextColors];
    [_sfinput1 setTextColor:[NSColor blackColor]];
    [_sfinput2 setTextColor:[NSColor blackColor]];
}

- (IBAction)setRulebaseThree:(id)sender {
    [_brain setRuleBaseNum: 3];
    [self resetTextColors];
}

- (void)resetTextColors {
    [_sfinput1 setTextColor:[NSColor grayColor]];
    [_sfinput2 setTextColor:[NSColor grayColor]];
    [_sfinput3 setTextColor:[NSColor grayColor]];
    [_sfinput4 setTextColor:[NSColor grayColor]];
}


// Fokus setzen
- (IBAction)gotoJahr:(id)sender {
    [self.window makeFirstResponder:_sfinputJahr];
}
- (IBAction)gotoMonat:(id)sender {
    [self.window makeFirstResponder:_sfinputMonat];
}
- (IBAction)gotoTag:(id)sender {
    [self.window makeFirstResponder:_sfinputTag];
}

- (IBAction)gotoTField1:(id)sender {
    [self.window makeFirstResponder:_sfinput1];
}
- (IBAction)gotoTField2:(id)sender {
    [self.window makeFirstResponder:_sfinput2];
}
- (IBAction)gotoTField3:(id)sender {
    [self.window makeFirstResponder:_sfinput3];
}
- (IBAction)gotoTField4:(id)sender {
    [self.window makeFirstResponder:_sfinput4];
}


- (IBAction)prevSourceRow:(id)sender {
    if (currentSourceRow > 0) {
        currentSourceRow--;
    } else {
        currentSourceRow = [_brain getCountOfPdfs] - 1;
    }
    [self setSelectedRowOfTable:_sourceTable toRow:currentSourceRow];
    [self showPDF];
    jsmDebug(@"%lu", currentSourceRow);
    [self.window makeFirstResponder:_sfinputTag];
}

- (IBAction)nextSourceRow:(id)sender {
    NSUInteger max = [_brain getCountOfPdfs];
    currentSourceRow++;
    if (currentSourceRow == max) {
        currentSourceRow = 0;
    }
    [self setSelectedRowOfTable:_sourceTable toRow:currentSourceRow];
    [self showPDF];
    [self.window makeFirstResponder:_sfinputTag];
}

- (IBAction)prevTargetRow:(id)sender {
    if (currentTargetRow > 0) {
        currentTargetRow--;
    } else {
        currentTargetRow = [_brain getCountOfFolders] - 1;
    }
    [self checkForRule];
    [self setSelectedRowOfTable:_targetTable toRow:currentTargetRow];
    [self.window makeFirstResponder:_sfinput1];
    [_brain setTargetPath:currentTargetRow];
}

- (IBAction)nextTargetRow:(id)sender {
    NSUInteger max = [_brain getCountOfFolders];
    currentTargetRow++;
    if (currentTargetRow == max) {
        currentTargetRow = 0;
    }
    [self checkForRule];
    [self setSelectedRowOfTable:_targetTable toRow:currentTargetRow];
    [self.window makeFirstResponder:_sfinput1];
    [_brain setTargetPath:currentTargetRow];
}


- (IBAction)changeSourceFolder:(id)sender {
    NSURL *url = [self chooseFolder];
    if(url != nil) {
        [self loadSourceFolder:url];
    }
}


- (IBAction)changeTargetRoot:(id)sender {
    NSURL *url = [self chooseFolder];
    if(url != nil) {
        [self loadTargetRoot:url];
    }
}


- (IBAction)createTargetSubfolder:(id)sender {
    if([_brain makeSubfolder: currentTargetRow])
    {
        NSUInteger futureRow = currentTargetRow + 1;
        if(futureRow >= [_brain getCountOfFolders]) {
            futureRow = 0;
        }
        targetFolder *t = [_brain gettarget:0];
        [self loadTargetRoot:[t url]];
        [self setSelectedRowOfTable:_targetTable toRow:futureRow];
    }
}




- (IBAction)switchMode:(NSMenuItem*)sender {
    [_brain switchMode];

    NSInteger colIdx;
    NSTableColumn* col;
    colIdx = [_sourceTable columnWithIdentifier:@"icon"];
    col = [_sourceTable.tableColumns objectAtIndex:colIdx];
    if( _brain.mode ) {
        [_targetTable setHidden:NO];
        [col setHidden:NO];
        [sender setState: NSOffState];
    } else {
        [_targetTable setHidden:YES];
        [col setHidden:YES];
        [sender setState: NSOnState];
    }
}




- (IBAction)showHelp:(id)sender {
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"pdf"];
    //    NSURL* url = [NSURL fileURLWithPath:path];
    //    PDFDocument *document = [[PDFDocument alloc] initWithURL: url];
    //    self.pdfviewer.document = document;
}






#pragma mark -
#pragma mark tools




/*----------------------------------------------------
 wird aufgerufen wenn zu einer eine zeile gewechselt wird
 -----------------------------------------------------*/
- (void)showPDF
{

    pdfdatei *pdf = [_brain getpdf:currentSourceRow];
    jsmDebug(@"showPDF: %lu\n%@", currentSourceRow, pdf);

    if ([pdf isNotEmpty:[pdf valueForKey:@"input_year"]]) { [_sfinputJahr setStringValue: [pdf valueForKey:@"input_year"]]; }
    if ([pdf isNotEmpty:[pdf valueForKey:@"input_mon"]]) { [_sfinputMonat setStringValue: [pdf valueForKey:@"input_mon"]]; }
    if ([pdf isNotEmpty:[pdf valueForKey:@"input_day"]]) { [_sfinputTag setStringValue: [pdf valueForKey:@"input_day"]]; }
    [_sfinput1 setStringValue: [pdf valueForKey:@"input_t1"]];
    [_sfinput2 setStringValue: [pdf valueForKey:@"input_t2"]];
    [_sfinput3 setStringValue: [pdf valueForKey:@"input_t3"]];
    [_sfinput4 setStringValue: [pdf valueForKey:@"input_t4"]];

    // pdf in view laden
    NSURL* url = [NSURL fileURLWithPath:[pdf valueForKey:@"fullSourcePath"]];
    PDFDocument *document = [[PDFDocument alloc] initWithURL: url];
    _pdfview.document = document;

    [self selectCorrespondingTargetRowForTargetPath:pdf.targetPath];
}


- (void)setPdfName
{
    if([_brain getCountOfPdfs] > 0) {

        // die inputs zusammensammeln
        NSArray *dateParts = @[[_sfinputJahr stringValue],[_sfinputMonat stringValue],[_sfinputTag stringValue]];
        NSArray *textParts = @[[_sfinput1 stringValue],[_sfinput2 stringValue],[_sfinput3 stringValue],[_sfinput4 stringValue]];
        // und ans brain schicken
        [_brain composePdfName:dateParts andText:textParts ofSourceRow:currentSourceRow withTargetRow:currentTargetRow];
        _hasModifiedNames = YES;

        // wenn nur ein einziges pdf im skat ist, muss die table reloaded werden, weil sich sonst das icon nicht ändert
        if( [_brain getCountOfPdfs] == 1) {
            [_sourceTable reloadData];
        }
        
    }
}


- (NSURL *) chooseFolder
{
    NSOpenPanel *panel = [NSOpenPanel openPanel]; //Create open panel dialog
    [panel setCanChooseFiles: false]; //Disable file selection
    [panel setCanChooseDirectories: true]; //Enable folder selection
    [panel setResolvesAliases: true]; //Enable alias resolving
    [panel setAllowsMultipleSelection: false]; //Disable multiple selection
    NSInteger result = [panel runModal]; //Display open panel

    if (result == NSFileHandlingPanelOKButton) {
        NSArray* urls = [panel URLs];
        NSURL *url = [urls objectAtIndex:0];
        if (url != nil) {
            return url;
        }
    }
    return nil;
}


// die nachfolgenden beiden methoden brauchts um auch mal unabhängig von den prefs einen anderen folder auszuwählen
- (void) loadSourceFolder: (NSURL *) url
{
    [_brain loadPdfsFromFolder:url];
    [self setSelectedRowOfTable:_sourceTable toRow:0];
    [self badge];
    [_sourceTable reloadData];
}



- (void) loadTargetRoot: (NSURL *) url
{
    [_brain loadTargetFolders:url];
    [_targetTable reloadData];
    [self setSelectedRowOfTable:_targetTable toRow:0];
}



- (void) setSelectedRowOfTable: (NSTableView *) table
                         toRow: (NSUInteger) row
{
    //if ( [_brain getCountOfPdfs] > 0 && [_brain getCountOfFolders] > 0) {
        [table selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [table scrollRowToVisible:row];
    //}
}

// http://stackoverflow.com/questions/11767557/scroll-an-nstableview-so-that-a-row-is-centered
// pos = index of desired row
// numRows = number of rows in the table
//NSRect visibleRect = [resultsTableView visibleRect];
//NSRange visibleRange = [resultsTableView rowsInRect:visibleRect];
//NSUInteger offset = visibleRange.length/2;
//NSUInteger i;
//if (pos + offset >= numRows)
//i = numRows - 1;
//else if (pos < visibleRange.length)
//i = pos;
//else
//i = pos + offset;
//[resultsTableView scrollRowToVisible:i];


- (void) badge {
    NSDockTile *dockTile = [NSApp dockTile];
    int remaining = (int) [_brain getCountOfPdfs];
    if(remaining > 0) {
        [dockTile setBadgeLabel:[NSString stringWithFormat:@"%i", remaining]];
    } else {
        [dockTile setBadgeLabel:nil];
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"pdf"];
        //        NSURL* url = [NSURL fileURLWithPath:path];
        //        PDFDocument *document = [[PDFDocument alloc] initWithURL: url];
        //        self.pdfviewer.document = document;
    }
}










#pragma mark -
#pragma mark tableview delegation methods

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [tableView scrollRowToVisible:row];
    if([[tableView identifier] isEqualToString:@"pdfs"]) {
        currentSourceRow = row;
        [self showPDF];
    } else {
        currentTargetRow = row;
        [_brain setTargetPath:row];
    }
	return YES;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if([[tableView identifier] isEqualToString:@"pdfs"]) {
        return [_brain getCountOfPdfs];
    } else {
        return [_brain getCountOfFolders];
    }
}

- (id) tableView: (NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)column row: (NSInteger)row {
    if([[tableView identifier] isEqualToString:@"pdfs"]) {
        pdfdatei *f = [_brain getpdf:row];
        if( f && [[column identifier] isEqualToString:@"filename"]) {
            return f.targetName;
        } else {
            return f.icon;
        }
    } else if ( [_brain getCountOfFolders] > 0 ) {
        targetFolder *f = [_brain gettarget:row];
        return f.indentedFolderName;
    }
    return nil;
}


/*
 die tabellenzeilen grau zu machen funktioniert nicht 
 weil er den zusammenhang von pdf.status zur farbe irgendwie nicht hinbekommt :(

- (void)tableView: (NSTableView *)tableView willDisplayCell: (id)cell forTableColumn: (NSTableColumn *)column row: (NSInteger)row
{
    NSColor *farbe = nil;
    if([[tableView identifier] isEqualToString:@"pdfs"] && [[column identifier] isEqualToString:@"filename"]) {
        pdfdatei *pdf = [_brain getpdf:row];
        if ( !pdf.icon ) {
            farbe = [NSColor grayColor];
        } else {
            farbe =[NSColor blackColor];
        }
        [cell setTextColor:farbe];
            //jsmDebug(@"%@ %lu", cell, row);
    }
}
*/



// holt den der regel entsprechenden target pfad
- (void)selectCorrespondingTargetRowForRulekey: (NSString *) rulekey {
    NSString *target = [_brain getTargetPathForKey:rulekey];
    if ( target != nil && [_brain getCountOfFolders] > 0 ) {
        // die entsprechende zeile im folders-array ermitteln und dann selektieren
        NSUInteger i = 0;
        for (targetFolder *f in _brain.folders)
        {
            if([f.fullPath isEqualToString:target]) {
                currentTargetRow = i;
                [_brain setTargetPath:currentTargetRow];
                [self setSelectedRowOfTable:_targetTable toRow:i];
                //jsmDebug(@"%@ = %@ = %lu", rulekey, f.fullPath, currentTargetRow);
                break;
            }
            i++;
        }
    }
}


// holt den der regel entsprechenden target pfad
- (void)selectCorrespondingTargetRowForTargetPath: (NSString *) path {
    if ( path != nil && [_brain getCountOfFolders] > 0 ) {
        //jsmDebug(@"%@", path);
        // die entsprechende zeile im folders-array ermitteln und dann selektieren
        NSUInteger i = 0;
        for (targetFolder *f in _brain.folders)
        {
            if([f.fullPath isEqualToString:path]) {
                currentTargetRow = i;
                [_brain setTargetPath:currentTargetRow];
                [self setSelectedRowOfTable:_targetTable toRow:i];
                jsmDebug(@"%lu: %@", currentTargetRow, f.fullPath);
                break;
            }
            i++;
        }
    }
}





#pragma mark -
#pragma mark search inputfield delegation


/*----------------------------------------------------
 den vier text inputs das jeweilie array mit vorauswahlen zuordnen
 aus dem apple sample code "SearchField"
 -----------------------------------------------------*/
- (NSArray *)control:(NSControl *)control
            textView:(NSTextView *)textView
         completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange
 indexOfSelectedItem:(int*)index
{

    NSMutableArray* matches = NULL;
    NSString*       partialString;
    NSArray*        keywords;
    NSInteger       i,count;
    NSString*       string;


    if ( [[control identifier] isEqualToString:@"part1"] ) {
        keywords = [_brain getRuleArray:1];
    } else if ( [[control identifier] isEqualToString:@"part2"] ) {
        keywords = [_brain getRuleArray:2];
    } else if ( [[control identifier] isEqualToString:@"part3"] ) {
        keywords = [_brain getRuleArray:3];
    } else if ( [[control identifier] isEqualToString:@"part4"] ) {
        keywords = [_brain getRuleArray:4];
    }
    //jsmDebug(@"control %@", [control identifier]);

    partialString = [[textView string] substringWithRange:charRange];
    count         = [keywords count];
    matches       = [NSMutableArray array];

    // find any match in our keyword array against what was typed -
    for (i=0; i< count; i++)
    {
        string = [keywords objectAtIndex:i];
        if ([string rangeOfString:partialString
                          options:NSAnchoredSearch | NSCaseInsensitiveSearch
                            range:NSMakeRange(0, [string length])].location != NSNotFound)
        {
            [matches addObject:string];
        }
    }
    [matches sortUsingSelector:@selector(compare:)];
    return matches;
}


// sobald im eingabefeld was geändert wird, nach einem eventuell zuzuordnenden targetfolder suchen
- (void)controlTextDidChange:(NSNotification *)obj
{
    // erstmal verhindern, dass diese funktion zu oft/schnell hintereinander aufgerufen wird
    NSTextView* textView = [[obj userInfo] objectForKey:@"NSFieldEditor"];
    if (!completePosting && !commandHandling)
    {
        completePosting = YES;
        [textView complete:nil];
        completePosting = NO;
    }

    // gibt es für den derzeitigen stand der eingabefelder schon eine regel?
    NSArray *textParts = @[[_sfinput1 stringValue],[_sfinput2 stringValue],[_sfinput3 stringValue],[_sfinput4 stringValue]];
    NSArray *filteredTextTeile = [textParts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    NSString *concatenatedString = [filteredTextTeile componentsJoinedByString:@" "];
    NSString *stringWithoutSlashes = [concatenatedString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    [self selectCorrespondingTargetRowForRulekey:stringWithoutSlashes];
}


/*----------------------------------------------------
 bei enter den aktuellen file-datensatz verarbeiten und dann zur nächsten zeile gehen
 bei den datums-inputs move up + down den jeweiligen wert des feldes entsprechend verändern
 -----------------------------------------------------*/
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    if( [textView respondsToSelector:commandSelector] && [_brain getCountOfPdfs] > 0 ) {
        if (commandSelector == @selector(insertNewline:) || commandSelector == @selector(insertLineBreak:)) {

            [self setPdfName];

            NSUInteger max = [_brain getCountOfPdfs];
            if(max > 1) {
                currentSourceRow++;
                if (currentSourceRow == max) {
                    currentSourceRow = 0;
                }
                [self setSelectedRowOfTable:_sourceTable toRow:currentSourceRow];
                [self showPDF];
            }
            [self.window makeFirstResponder:_sfinputTag];
            retval = YES; // causes Apple to NOT fire the default enter action

        } else if (commandSelector == @selector(moveUp:) || commandSelector == @selector(moveDown:) ) {
            NSInteger mytag = [control tag];
            if (mytag >= 10 && mytag <= 12) {
                NSInteger val = [[textView string] integerValue];
                if (commandSelector == @selector(moveUp:) ) {
                    ++val;
                } else {
                    --val;
                }
                if (val < 1) {
                    if ( mytag == 11 ) {
                        val = 12;
                    } else if ( mytag == 12 ) {
                        val = 31;
                    }
                }
                [control setStringValue: [NSString stringWithFormat:@"%02lu",val]];
                retval = YES;
            }
        }
    }
    return retval;
}




@end

//
//  mainWindowController.h
//  PDFiler
//
//  Created by Tom Nakat on 12.07.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "renamerBrain.h"

@interface mainWindowController : NSWindowController <NSTableViewDelegate, NSTextDelegate>
{
    // für das laden von mandanten
    IBOutlet NSPanel        *selectMandantSheet;
    IBOutlet NSPanel        *switchTomHnSheet;
    IBOutlet NSView         *progressBox;
    IBOutlet NSProgressIndicator *spinningWheel;

    // für die auto-input-felder
    NSMutableArray          *allKeywords;
    NSMutableArray          *builtInKeywords;
    BOOL                    completePosting;
    BOOL                    commandHandling;
    IBOutlet NSView *mainview;
}


#pragma mark -
#pragma mark vars

@property (nonatomic, strong) renamerBrain *brain;
@property (nonatomic, strong) NSString *currentMandant;
@property (nonatomic) BOOL  hasModifiedNames; // zur warnung beim schließen des fensters




#pragma mark -
#pragma mark IB Outlets

@property (weak) IBOutlet NSTableView *sourceTable;
@property (weak) IBOutlet NSTableView *targetTable;

@property (weak) IBOutlet NSSearchField *sfinputJahr;
@property (weak) IBOutlet NSSearchField *sfinputMonat;
@property (weak) IBOutlet NSSearchField *sfinputTag;
@property (weak) IBOutlet NSSearchField *sfinput1;
@property (weak) IBOutlet NSSearchField *sfinput2;
@property (weak) IBOutlet NSSearchField *sfinput3;
@property (weak) IBOutlet NSSearchField *sfinput4;

@property (weak) IBOutlet PDFView *pdfview;
@property (weak) IBOutlet NSView *editSplit;
@property (weak) IBOutlet NSView *pdfSplit;

@property (strong) IBOutlet NSPanel *mandantenAuswahlWindow;
@property (weak) IBOutlet NSTextField *mandant2load; // hier wird der code des mandanten im sheet eingegeben
@property (weak) IBOutlet NSButton *mandantenAuswahlDefaultButton;


@end

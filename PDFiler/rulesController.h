//
//  rulesController.h
//  PDFiler
//
//  Created by Tom Nakat on 24.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class renamerBrain;

@interface rulesController : NSWindowController //<NSTableViewDelegate>


@property (nonatomic, strong) renamerBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *regeln;

@property (weak) IBOutlet NSTableView *rulesTable;
@property (strong) IBOutlet NSDictionaryController *dict;

@end

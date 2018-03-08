//
//  PrefController.h
//  PDFiler
//
//  Created by Tom Nakat on 11.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class renamerBrain;

@interface PrefController : NSWindowController

@property (nonatomic, strong) renamerBrain *brain;

@property (nonatomic, strong) NSURL *sourcePath;
@property (nonatomic, strong) NSURL *targetPath;

@property (weak) IBOutlet NSTextField *glueCharacter;
@property (weak) IBOutlet NSTextField *sourceFolderValue;
@property (weak) IBOutlet NSTextField *targetRootValue;
@property (weak) IBOutlet NSTextField *glueCharacterDemo;
@property (weak) IBOutlet NSButton *fullscreenCheckbox;


- (NSURL*) chooseFolder;

@end

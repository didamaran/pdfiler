//
//  renamerBrain.h
//  PDFiler
//
//  Created by Tom Nakat on 28.08.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class targetFolder;
@class pdfdatei;

@interface renamerBrain : NSObject


@property (nonatomic) BOOL                         mode; // nur umbenennen (NO) oder auch verschieben (YES, Standard)
@property (nonatomic, retain) NSMutableArray       *files; // array of file-objects
@property (nonatomic, retain) NSMutableArray       *folders; // array of file-objects
@property (nonatomic, retain) NSMutableDictionary  *rules; // regeln
@property (nonatomic, retain) NSMutableDictionary  *mprefs; // mandantenspezifische prefs

//@property (nonatomic, retain) NSMutableArray       *mandanten;

@property (nonatomic, strong) NSMutableArray       *ruleWords_1;
@property (nonatomic, strong) NSMutableArray       *ruleWords_2;
@property (nonatomic, strong) NSMutableArray       *ruleWords_3;
@property (nonatomic, strong) NSMutableArray       *ruleWords_4;


-(void) setMandant: (NSString*) man;
-(void) loadMandant;
-(void) loadPdfsFromFolder: (NSURL *) url;
-(void) loadTargetFolders: (NSURL *) insideOfUrl;
-(BOOL) makeSubfolder: (NSUInteger) row;

-(void) composePdfName: (NSArray *)dateParts
               andText: (NSArray *) textParts
           ofSourceRow: (NSInteger) i
         withTargetRow: (NSInteger) t;

-(void) overrideTargetofSourceRow: (NSInteger) i
                    withTargetRow: (NSInteger) t
                     changingRule: (BOOL) b;

-(void) setRuleBaseNum: (NSUInteger) n;
-(void) setTargetPath: (NSUInteger) rowOfTargets;
-(void) switchMode;
//-(void) deleteRule: (NSString *) key;
-(void) processFiles;

-(NSString *) getCurrentTargetPath;
-(NSMutableArray *) getRuleArray: (NSUInteger) i;

-(pdfdatei *) getpdf: (NSInteger) i;
-(NSInteger) getCountOfPdfs;
-(targetFolder *) gettarget: (NSInteger) i;
-(NSInteger) getCountOfFolders;
-(NSInteger) getCountOfRules;
-(NSString *) getTargetPathForKey: (NSString *) key;
-(NSString *) getMandant;

-(NSMutableDictionary *) getRegeln;

@end

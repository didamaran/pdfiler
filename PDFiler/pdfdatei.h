//
//  pdfdatei.h
//
//  Created by Tom Nakat on 03.04.13.
//  Copyright (c) 2013 zenziware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pdfdatei : NSObject

@property (nonatomic, copy) NSString *originalName;
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, copy) NSString *targetFolder;
@property (nonatomic, copy) NSString *targetPath;
@property (nonatomic, copy) NSString *fullTargetPath;
@property (nonatomic, copy) NSString *fullSourcePath;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *ruleKey;
@property (nonatomic, copy) NSDate *modificationDate;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) NSImage *icon;
@property NSUInteger targetIndex;
@property int myIndex;
@property long long int fileSize;

@property (nonatomic, copy) NSString *input_year;
@property (nonatomic, copy) NSString *input_mon;
@property (nonatomic, copy) NSString *input_day;
@property (nonatomic, copy) NSString *input_t1;
@property (nonatomic, copy) NSString *input_t2;
@property (nonatomic, copy) NSString *input_t3;
@property (nonatomic, copy) NSString *input_t4;


-(void) setNameWithDate: (NSArray *)dateParts andText: (NSArray *) textParts keyNum: (NSUInteger) ruleBase;
-(void) setTarget: (NSString *)path targetRow: (NSUInteger)row byRule: (BOOL) reruled;
-(void) setState: (int)statusKonstante;
-(BOOL) isNotEmpty: (NSString *)string;
-(void) setDemoName;


@end

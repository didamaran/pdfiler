//
//  targetFolder.h
//  PDFiler
//
//  Created by Tom Nakat on 30.08.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface targetFolder : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *fullPath;
@property (nonatomic, copy) NSString *relativePath;
@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, copy) NSString *indentedFolderName;
@property (nonatomic) NSUInteger index;


- (id)initWithUrl: (NSURL*) url andIndex: (NSUInteger) i resetDepth: (BOOL) to;

@end

//
//  targetFolder.m
//  PDFiler
//
//  Created by Tom Nakat on 30.08.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "targetFolder.h"
#import "Constants.h"

@implementation targetFolder


static NSUInteger depth = 0;


- (id)initWithUrl: (NSURL*) theURL andIndex: (NSUInteger) i resetDepth:(BOOL)to
{
    self = [super init];
    if (self) {

        if(to) {
            depth = 0;
        }

        _url = theURL; // = url-encoded! zb: file://localhost/Users/tomme/Documents/bike/FONTS/Vectora%20LH/
        _fullPath = [[NSString alloc] initWithFormat:@"%@", [theURL path]]; // = decoded pfad zb: /Users/tomme/Documents/bike/FONTS/Vectora LH/

        NSString *name;
        [theURL getResourceValue:&name forKey:NSURLNameKey error:NULL];
        _folderName = name;

        // alle teile vor dem root-folder abschneiden
        NSArray *fullPathParts = [_fullPath componentsSeparatedByString:@"/"];
        NSUInteger n = [fullPathParts count];
        if( depth == 0 ) { // das wird nur beim ersten aufruf durchgeführt
            depth = n - 1;
        }
        NSMutableArray *relPathParts = [[NSMutableArray alloc] init];
        NSMutableArray *prePathParts = [[NSMutableArray alloc] init];
        if(depth > 0) {
            for ( NSUInteger i = depth; i < n; i++ ) {
                [relPathParts addObject:[fullPathParts objectAtIndex:i]];
            }
            for ( NSUInteger i = (depth+1); i < n; i++ ) {
                [prePathParts addObject:PRE_TARGET];
            }
        }
        _relativePath = [relPathParts componentsJoinedByString:@"/"];
        _indentedFolderName = [NSString stringWithFormat:@"%@%@", [prePathParts componentsJoinedByString:@""], _folderName];

    }

    //jsmDebug(@"%@", self);
    return self;
}


-(NSString *) description {
    return [NSString stringWithFormat:@"\n++++++++++++++++++++++++++\nurl: %@\nfull: %@\nrelative: %@\nname: %@\nindented: %@\n%lu\n++++++++++++++++++++++++++\n\n", _url, _fullPath, _relativePath, _folderName, _indentedFolderName, depth];
}


@end

//
//  whiteView.m
//  PDFiler
//
//  Created by Tom Nakat on 24.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "whiteView.h"

@implementation whiteView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

@end

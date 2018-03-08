//
//  darkView.m
//  PDFiler
//
//  Created by Tom Nakat on 25.09.13.
//  Copyright (c) 2013 Tom Nakat. All rights reserved.
//

#import "darkView.h"
#import "Constants.h"

@implementation darkView

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
    NSColor *c = [NSColor colorWithCalibratedRed:(PDF_BACK_COLOR/255.0f) green:(PDF_BACK_COLOR/255.0f) blue:(PDF_BACK_COLOR/255.0f) alpha:1.0];
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:c];
    [aGradient drawInRect:[self bounds] angle:270];
    /*
    [c setFill];
    NSRectFill(dirtyRect);
     */
}

@end

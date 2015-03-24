//
//  PXEraserTool.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXEraserTool.h"

#import "PXCanvas.h"
#import "PXPalette.h"
#import "PXCanvas_Layers.h"

@implementation PXEraserTool

- (NSString *)name
{
	return NSLocalizedString(@"ERASER_NAME", @"Eraser Tool");
}

- (PXColor)colorForCanvas:(PXCanvas *)canvas
{
	return [canvas eraseColor];
}

@end

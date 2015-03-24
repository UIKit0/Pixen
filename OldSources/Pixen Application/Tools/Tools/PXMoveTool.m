//
//  PXMoveTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXMoveTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvasDocument.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "PXImage.h"

@implementation PXMoveTool

- (PXToolPropertiesController *)createPropertiesController
{
	return nil;
}

- (NSString *)name
{
	return NSLocalizedString(@"MOVE_NAME", @"Move Tool");
}

- (NSCursor *)cursor
{
	return [NSCursor openHandCursor];
}

- (BOOL)supportsPatterns
{
	return NO;
}

- (void)startMovingSelectionFromPoint:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	PXLayer *activeLayer = [canvas activeLayer];
	
	[[[canvas undoManager] prepareWithInvocationTarget:canvas] restoreColorData:[activeLayer colorData] onLayer:activeLayer];
	
	lastSelectedRect = selectedRect = [canvas selectedRect]; // O(N)
	selectionOrigin = selectedRect.origin;
	
	moveLayer = [[PXLayer alloc] initWithName:NSLocalizedString(@"Temp Layer", @"Temp Layer")
										 size:selectedRect.size];
	[moveLayer setCanvas:canvas];
	[moveLayer setOpacity:[[canvas activeLayer] opacity]];
	
	// we clear the selected area in the active layer and copy the selected pixels
	// into a pximage of our own to be drawn each frame. whoo.
	// this is O(N), incidentally. but just over selected pixels, not the whole canvas.
	PXColor clear = [canvas eraseColor];
	int i, j;
	
	[canvas beginColorUpdates];
	
	for (i = NSMinX(selectedRect); i < NSMaxX(selectedRect); i++)
	{
		for (j = NSMinY(selectedRect); j < NSMaxY(selectedRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			
			if (![canvas pointIsSelected:point])
				continue;
			
			[canvas setColor:[canvas colorAtPoint:point]
					 atPoint:NSMakePoint(i - selectedRect.origin.x, j - selectedRect.origin.y)
					 onLayer:moveLayer];
			
			[canvas setColor:clear atPoint:point];
		}
	}
	
	[canvas endColorUpdates];
	
	[moveLayer moveToPoint:selectedRect.origin]; // move to initial point
	[canvas addTempLayer:moveLayer];
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	
	if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
		type = PXMoveTypeCopying;
	}
	else {
		type = PXMoveTypeMoving;
	}
	
	PXCanvas *canvas = [controller canvas];
	[canvas beginUndoGrouping];
	
	if ([canvas hasSelection])
	{
		entireImage = NO;
		[self startMovingSelectionFromPoint:aPoint fromCanvasController:controller];
	}
	else {
		entireImage = YES;
		moveLayer = [canvas activeLayer];
		selectionOrigin = NSZeroPoint;
	}
	
	if (type == PXMoveTypeCopying) {
		[self updateCopyLayerForCanvas:canvas];
	}
}

- (void)updateCopyLayerForCanvas:(PXCanvas *)canvas
{
	if (!entireImage) {
		if (type == PXMoveTypeCopying) {
			copyLayer = [moveLayer copy];
			[copyLayer moveToPoint:selectionOrigin];
			
			[canvas insertTempLayer:copyLayer atIndex:0];
		}
		else if (type == PXMoveTypeMoving) {
			[canvas removeTempLayer:copyLayer];
			copyLayer = nil;
		}
	}
	else {
		if (type == PXMoveTypeMoving) {
			NSPoint origin = [copyLayer origin];
			
			[canvas removeTempLayer:copyLayer];
			copyLayer = nil;
			
			[moveLayer moveToPoint:origin];
		}
		else if (type == PXMoveTypeCopying) {
			NSPoint origin = [moveLayer origin];
			[moveLayer moveToPoint:NSZeroPoint];
			
			copyLayer = [moveLayer copy];
			[copyLayer moveToPoint:origin];
			
			[canvas insertTempLayer:copyLayer atIndex:0];
		}
	}
}

- (void)drawFromPoint:(NSPoint)initialPoint
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *)canvas
{
	float dx = (finalPoint.x - initialPoint.x), dy = (finalPoint.y - initialPoint.y);
	
	if (!entireImage)
	{
		selectedRect.origin = NSMakePoint(selectionOrigin.x + dx, selectionOrigin.y + dy);
		[moveLayer moveToPoint:selectedRect.origin];
		
		[canvas setSelectionOrigin:NSMakePoint(dx, dy)];
		[canvas changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		
		lastSelectedRect = selectedRect;
	}
	else
	{
		if (type == PXMoveTypeMoving) {
			[[canvas activeLayer] moveToPoint:NSMakePoint(dx, dy)];
		}
		else if (type == PXMoveTypeCopying) {
			[copyLayer moveToPoint:NSMakePoint(dx, dy)];
		}
		
		[canvas changedInRect:NSMakeRect(0.0f, 0.0f, [canvas size].width, [canvas size].height)];
	}
}

- (BOOL)supportsAdditionalLocking
{
	return YES;
}

- (void)finalDrawFromPoint:(NSPoint)initialPoint
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *)canvas
{
	if (!entireImage)
	{
		selectedRect = lastSelectedRect;
		
		if (type == PXMoveTypeCopying)
		{
			[copyLayer setSize:[canvas size]];
			[copyLayer finalizeMotion];
			
			[[canvas activeLayer] compositeUnder:copyLayer flattenOpacity:YES];
			
			[canvas removeTempLayer:copyLayer];
			copyLayer = nil;
		}
		
		[moveLayer setSize:[canvas size]];
		[moveLayer finalizeMotion];
		
		[[canvas activeLayer] compositeUnder:moveLayer flattenOpacity:YES];
		
		[canvas removeTempLayer:moveLayer];
		moveLayer = nil;
		
		[canvas finalizeSelectionMotion];
		[canvas changed];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName
															object:canvas];
	}
	else
	{
		[canvas moveLayer:moveLayer byOffset:[moveLayer origin]];
		[moveLayer moveToPoint:NSZeroPoint];
		
		if (type == PXMoveTypeCopying)
		{
			[copyLayer setSize:[canvas size]];
			[copyLayer finalizeMotion];
			
			[[canvas activeLayer] compositeUnder:copyLayer flattenOpacity:YES];
			
			[canvas removeTempLayer:copyLayer];
			copyLayer = nil;
		}
		
		entireImage = NO;
		moveLayer = nil;
	}
	
	type = PXMoveTypeNone;
	[canvas endUndoGrouping];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	NSPoint nudgeDest = NSZeroPoint;
	int nudgeAmount = 1;
	
	if (([event modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask) {
		nudgeAmount = 10;
	}
	
	unichar key = [[event characters] characterAtIndex:0];
	
	if (key == NSUpArrowFunctionKey && !([event modifierFlags] & NSCommandKeyMask)) {
		nudgeDest.y = nudgeAmount;
	}
	else if (key == NSRightArrowFunctionKey) {
		nudgeDest.x = nudgeAmount;
	}
	else if (key == NSDownArrowFunctionKey && !([event modifierFlags] & NSCommandKeyMask)) {
		nudgeDest.y = -nudgeAmount;
	}
	else if (key == NSLeftArrowFunctionKey) {
		nudgeDest.x = -nudgeAmount;
	}
	
	if (!NSEqualPoints(nudgeDest, NSZeroPoint)) {
		[self mouseDownAt:NSZeroPoint fromCanvasController:cc];
		[self mouseDraggedFrom:NSZeroPoint to:nudgeDest fromCanvasController:cc];
		[self mouseUpAt:nudgeDest fromCanvasController:cc];
	}
}

- (BOOL)optionKeyDown
{
	if (type == PXMoveTypeNone)
		return YES;
	
	type = PXMoveTypeCopying;
	
	PXCanvasDocument *doc = (PXCanvasDocument *) [[NSDocumentController sharedDocumentController] currentDocument];
	[self updateCopyLayerForCanvas:[[doc canvasController] canvas]];
	
	return YES;
}

- (BOOL)optionKeyUp
{
	if (type == PXMoveTypeNone)
		return YES;
	
	type = PXMoveTypeMoving;
	
	PXCanvasDocument *doc = (PXCanvasDocument *) [[NSDocumentController sharedDocumentController] currentDocument];
	[self updateCopyLayerForCanvas:[[doc canvasController] canvas]];
	
	return YES;
}

@end

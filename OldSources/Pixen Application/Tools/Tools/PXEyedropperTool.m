//
//  PXEyedropperTool.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXEyedropperTool.h"

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasController.h"
#import "PXEyedropperToolPropertiesController.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"

@implementation PXEyedropperTool

#define EYE_PC ((PXEyedropperToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"EYEDROPPER_NAME", @"Eyedropper Tool");
}

- (PXToolPropertiesController *)createPropertiesController
{
	return [PXEyedropperToolPropertiesController new];
}

- (NSCursor *)cursor
{
	return [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"eyedropper_bw.png"]
									hotSpot:NSMakePoint(14.0f, 14.0f)];
}

/*
 
 - propertiesView
 {
 //FIXME immense HACK ohgodimsorry
 if ([[PXToolPaletteController sharedToolPaletteController] leftTool] == self)
 [(PXEyedropperToolPropertiesController *) self.propertiesController setButtonType:PXLeftButtonTool];
 else
 [(PXEyedropperToolPropertiesController *) self.propertiesController setButtonType:PXRightButtonTool];
 
 return propertiesView;	
 }
 
 */

- (PXColor)compositeColorAtPoint:(NSPoint)aPoint fromCanvas:(PXCanvas *)canvas
{
	if (![canvas containsPoint:aPoint])
	{
		NSAssert(0, @"[PXEyedropperTool compositeColorAtPoint:fromCanvas:] - the given point is outside canvas bounds (this should never execute)");
	}
	
	if ([EYE_PC colorSource] == PXActiveLayerColorSource)
	{
		return [[canvas activeLayer] colorAtPoint:aPoint];
	}
	
	return [canvas surfaceColorAtPoint:aPoint];
}

- (void)eyedropAtPoint:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	if (![[controller canvas] containsPoint:aPoint])
		return;
	
	PXToolSwitcher *usedSwitcher;
	
	if ([EYE_PC buttonType] == PXLeftButtonTool)
		usedSwitcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	else
		usedSwitcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	
	[usedSwitcher setColor:PXColorToNSColor([self compositeColorAtPoint:aPoint fromCanvas:[controller canvas]])];
}


- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	[self eyedropAtPoint:aPoint fromCanvasController:controller];
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint
	fromCanvasController:(PXCanvasController *)controller
{
	[self eyedropAtPoint:finalPoint fromCanvasController:controller];
}

- (void)mouseUpAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	[self eyedropAtPoint:aPoint fromCanvasController:controller];
}

@end

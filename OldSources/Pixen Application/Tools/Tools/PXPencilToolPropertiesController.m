//
//  PXPencilToolPropertiesController.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXPencilToolPropertiesController.h"
#import "PXCanvasDocument.h"
#import "PXPattern.h"
#import "PXCanvasController.h"
#import "PXNotifications.h"
#import "PXSelectPatternController.h"

@interface PXPencilToolPropertiesController () < PXSelectPatternControllerDelegate >
@end


@implementation PXPencilToolPropertiesController {
	NSPopover *_popover;
}

@synthesize lineThicknessField, patternButton, clearButton;
@synthesize lineThickness, pattern = drawingPattern, toolName;

- (NSString *)nibName
{
    return @"PXPencilToolPropertiesView";
}

- (void)setPattern:(PXPattern *)pattern
{
	if (drawingPattern != pattern) {
		drawingPattern = pattern;
		
		[lineThicknessField setEnabled:NO];
		[clearButton setEnabled:YES];
	}
}

- (NSSize)patternSize
{
	if (drawingPattern != nil) {
		return [drawingPattern size];
	}
	
	return NSZeroSize;
}

- (NSArray *)drawingPoints
{
	return [drawingPattern pointsInPattern];
}

- (IBAction)clearPattern:(id)sender
{
	drawingPattern = nil;
	
	[lineThicknessField setEnabled:YES];
	[clearButton setEnabled:NO];
}

- (IBAction)showPatterns:(id)sender
{
	if (_popover) {
		[_popover close];
		_popover = nil;
	}
	
	PXSelectPatternController *selector = [PXSelectPatternController new];
	selector.delegate = self;
	
	_popover = [[NSPopover alloc] init];
	_popover.contentViewController = selector;
	_popover.behavior = NSPopoverBehaviorApplicationDefined;
	
	selector.popover = _popover;
	
	[_popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}

- (void)selectPatternControllerDidChoosePattern:(PXPattern *)pattern
{
	if (pattern == nil)
		return;
	
	[self setPattern:pattern];
}

- (void)awakeFromNib
{
	[self clearPattern:nil];
}

- (id)init
{
	self = [super init];
	if (self) {
		self.lineThickness = 1;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

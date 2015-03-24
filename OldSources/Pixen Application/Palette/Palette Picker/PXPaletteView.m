//
//  PXPaletteView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen. All rights reserved.
//

#import "PXPaletteView.h"

#import "PXInsertionView.h"
#import "PXPaletteColorView.h"

@interface PXPaletteView ()

@property (nonatomic, assign) NSUInteger selectionIndex;

@end


@implementation PXPaletteView

const CGFloat viewMargin = 1.0f;

@synthesize allowsColorSelection, allowsColorModification, controlSize, palette, delegate;
@synthesize selectionIndex;

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		_allowsFirstResponder = YES;
		
		_visibleViews = [NSMutableSet new];
		_recycledViews = [NSMutableSet new];
		
		selectionIndex = NSNotFound;
		controlSize = NSRegularControlSize;
		allowsColorSelection = allowsColorModification = YES;
		
		_clickedCelIndex = NSNotFound;
		
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeColor]];
	}
	return self;
}

- (void)viewDidMoveToSuperview
{
	NSView *superview = [self superview];
	
	if ([superview isKindOfClass:[NSClipView class]]) {
		[superview setPostsBoundsChangedNotifications:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scrollViewDidScroll:)
													 name:NSViewBoundsDidChangeNotification
												   object:superview];
		
		[self performSelector:@selector(reload) withObject:nil afterDelay:0.0f];
	}
}

- (void)scrollViewDidScroll:(NSNotification *)notification
{
	[self retile];
}

- (BOOL)acceptsFirstResponder
{
	return _allowsFirstResponder;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor colorWithCalibratedWhite:0.95f alpha:1.0f] set];
	NSRectFill(dirtyRect);
}

- (void)reload
{
	for (PXPaletteColorView *view in _visibleViews)
	{
		[_recycledViews addObject:view];
		[view removeFromSuperview];
	}
	
	[_visibleViews minusSet:_recycledViews];
	
	[self size];
	[self retile];
}

- (void)selectColorAtIndex:(NSUInteger)index
{
	self.selectionIndex = index;
	
	[self reload];
}

- (int)celSize
{
	return (controlSize == NSRegularControlSize ? 32 : 16);
}

- (void)size
{
	width = [self celSize] + viewMargin;
	columns = NSWidth([self bounds]) / width;
	rows = palette ? ceilf((float)(([palette colorCount])) / columns) : 0;
	
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * width + viewMargin*2, NSHeight([[self superview] bounds])))];
}

- (void)viewDidEndLiveResize
{
	[self reload];
}

- (PXPaletteColorView *)dequeueRecycledView
{
	PXPaletteColorView *view = [_recycledViews anyObject];
	
	if (view) {
		[_recycledViews removeObject:view];
	}
	
	return view;
}

- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
	for (PXPaletteColorView *view in _visibleViews) {
		if (view.index == index)
			return YES;
	}
	
	return NO;
}

- (void)retile
{
	if (!palette)
		return;
	
	NSRect visibleBounds = [[self superview] bounds];
	
	NSInteger firstIndex = floorf(NSMinY(visibleBounds) / width) * columns;
	NSInteger lastIndex = ceilf(NSMaxY(visibleBounds) / width) * columns + columns;
	
	firstIndex = MAX(firstIndex, 0);
	lastIndex = MIN(lastIndex, MAX([palette colorCount], 1) - 1);
	
	// Recycle no-longer-visible views
	for (PXPaletteColorView *view in _visibleViews)
	{
		if (view.index < firstIndex || view.index > lastIndex) {
			[_recycledViews addObject:view];
			[view removeFromSuperview];
		}
	}
	
	[_visibleViews minusSet:_recycledViews];
	
	if (![palette colorCount]) {
		return;
	}
	
	// add missing views
	for (NSUInteger n = firstIndex; n <= lastIndex; n++)
	{
		if ([self isDisplayingViewForIndex:n])
			continue;
		
		PXPaletteColorView *view = [self dequeueRecycledView];
		
		NSUInteger i = n % columns;
		NSUInteger j = n / columns;
		
		NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*width, width - viewMargin*2, width - viewMargin*2);
		
		if (!view) {
			view = [[PXPaletteColorView alloc] initWithFrame:frame];
		}
		else {
			[view setFrame:frame];
		}
		
		view.index = n;
		view.color = PXColorToNSColor([palette colorAtIndex:n]);
		view.controlSize = controlSize;
		view.highlighted = (n == selectionIndex);
		
		[self addSubview:view];
		
		[_visibleViews addObject:view];
	}
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (void)setPalette:(PXPalette *)pal
{
	if (palette != pal)
	{
		self.selectionIndex = NSNotFound;
		
		palette = pal;
		
		[self reload];
	}
}

- (void)rightMouseDown:(NSEvent *)event
{
	[self mouseDown:event];
}

- (void)rightMouseDragged:(NSEvent *)event
{
	[self mouseDragged:event];
}

- (void)rightMouseUp:(NSEvent *)event
{
	[self mouseUp:event];
}

- (NSUInteger)indexOfCelAtPoint:(NSPoint)point
{
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / width), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / width), rows-1);
	
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			NSUInteger index = j * columns + i;
			
			if (index >= [palette colorCount])
				break;
			
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*width, width - viewMargin*2, width - viewMargin*2);
			
			if (NSPointInRect(point, frame))
				return index;
		}
	}
	
	return NSNotFound;
}

- (void)setControlSize:(NSControlSize)aSize
{
	if (controlSize != aSize) {
		controlSize = aSize;
		
		[self reload];
	}
}

- (void)deleteBackward:(id)sender
{
	if (!palette)
		return;
	
	if (selectionIndex == NSNotFound || !palette.canSave) {
		NSBeep();
		return;
	}
	
	[palette removeColorAtIndex:selectionIndex];
	[palette save];
	
	if (selectionIndex >= [palette colorCount])
		self.selectionIndex = NSNotFound;
	
	[self reload];
}

- (void)moveLeft:(id)sender
{
	if (selectionIndex > 0 && selectionIndex != NSNotFound) {
		NSUInteger index = selectionIndex;
		
		[self toggleHighlightOnViewAtIndex:selectionIndex];
		index--;
		[self toggleHighlightOnViewAtIndex:index];
		
		if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
			[delegate useColorAtIndex:index];
	}
	else {
		NSBeep();
	}
}

- (void)moveRight:(id)sender
{
	if (selectionIndex < ([palette colorCount]-1) && selectionIndex != NSNotFound) {
		NSUInteger index = selectionIndex;
		
		[self toggleHighlightOnViewAtIndex:selectionIndex];
		index++;
		[self toggleHighlightOnViewAtIndex:index];
		
		if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
			[delegate useColorAtIndex:index];
	}
	else {
		NSBeep();
	}
}

- (void)toggleHighlightOnViewAtIndex:(NSUInteger)index
{
	if (!allowsColorSelection)
		return;
	
	for (NSView *view in [self subviews])
	{
		if (![view isKindOfClass:[PXPaletteColorView class]])
			continue;
		
		PXPaletteColorView *colorView = (PXPaletteColorView *) view;
		
		if (index == colorView.index) {
			if (colorView.highlighted) {
				colorView.highlighted = NO;
				self.selectionIndex = NSNotFound;
			}
			else {
				colorView.highlighted = YES;
				self.selectionIndex = index;
			}
			
			break;
		}
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (!allowsColorSelection)
		return; // disable moveRight:, moveLeft:, and deleteBackward:
	
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)activateIndexWithEvent:(NSEvent *)event
{
	if (selectionIndex != NSNotFound) {
		[self toggleHighlightOnViewAtIndex:selectionIndex];
	}
	
	if (!palette)
		return;
	
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	if (index == NSNotFound)
		return;
	
	[self toggleHighlightOnViewAtIndex:index];
	
	if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
		[delegate useColorAtIndex:index];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	if (!palette || !palette.canSave)
		return NSDragOperationNone;
	
	NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	if (index == NSNotFound)
		return NSDragOperationNone;
	
	return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	NSArray *colors = [[sender draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSColor class]]
																 options:nil];
	
	if (![colors count])
		return NO;
	
	NSColor *color = [[colors objectAtIndex:0] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	[palette replaceColorAtIndex:index withColor:PXColorFromNSColor(color)];
	[palette save];
	
	[self reload];
	
	return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
	[self retile];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
	return self;
}

- (int)proposedCelIndexAtPoint:(NSPoint)point
{
	int row = point.y / width;
	int col = (point.x + [self celSize] / 2) / width;
	
	return row * columns + col;
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	if (index == NSNotFound)
		return;
	
	if ([event clickCount] == 2 && allowsColorModification) {
		if ([delegate respondsToSelector:@selector(paletteView:modifyColorAtIndex:)])
			[delegate paletteView:self modifyColorAtIndex:index];
	}
	else if ([event clickCount] == 1 && palette.canSave) {
		_clickedCelIndex = index;
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	[self autoscroll:event];
	
	if (_clickedCelIndex != NSNotFound) {
		_dragging = YES;
		
		NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
		point.x = (int) ((point.x + [self celSize] / 2) / width) * width;
		point.y = (int) (point.y / width) * width;
		
		int n = [self proposedCelIndexAtPoint:point];
		
		if (n > [palette colorCount])
			return;
		
		if (!_insertionView) {
			_insertionView = [[PXInsertionView alloc] initWithFrame:NSZeroRect];
			[self addSubview:_insertionView];
		}
		
		_insertionView.frame = NSMakeRect(point.x, point.y, 2.0f, [self celSize] + viewMargin * 2);
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if (_dragging) {
		int n = [self proposedCelIndexAtPoint:_insertionView.frame.origin];
		
		[palette moveColorAtIndex:_clickedCelIndex toIndex:n];
		
		self.selectionIndex = NSNotFound;
		[self reload];
		
		[_insertionView removeFromSuperview];
		_insertionView = nil;
		
		_clickedCelIndex = NSNotFound;
		_dragging = NO;
		
		return;
	}
	
	[self activateIndexWithEvent:event];
}

@end

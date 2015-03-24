//
//  PXCanvasWindowController.m
//  Pixen
//

#import "PXDocumentController.h"

#import "PXAnimationWindowController.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_Toolbar.h"
#import "PXCanvasWindowController_Info.h"
#import "PXCanvasWindowController_Zooming.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXCanvasController.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasView.h"
#import "PXLayerController.h"
#import "PXCanvasResizePrompter.h"
#import "PXScaleController.h"
#import "PXGridSettingsController.h"
#import "PXCanvasDocument.h"
#import "PXPaletteController.h"
#import "PXInfoView.h"
#import "PXPreviewController.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"
#import "PXTool.h"
#import "PXToolPropertiesController.h"

//Taken from a man calling himself "BROCK BRANDENBERG" 
//who is here to save the day.
#import "SBCenteringClipView.h"

@implementation PXCanvasWindowController {
	PXToolPropertiesController *_propertiesController;
}

@synthesize scaleController, canvasController, resizePrompter = _resizePrompter, canvas;
@synthesize splitView, sidebarSplit, layerSplit, canvasSplit, paletteSplit;
@synthesize draggingOrigin = _draggingOrigin;

- (PXCanvasView *)view
{
	return [canvasController view];
}

- (id)initWithWindowNibName:(NSString *)name
{
	if (! ( self = [super initWithWindowNibName:name] ) ) 
		return nil;
	layerController = [[PXLayerController alloc] init];
	[layerController setNextResponder:self];
	paletteController = [[PXPaletteController alloc] init];

	return self;
}

- (PXScaleController *)scaleController
{
	if (!scaleController) {
		scaleController = [[PXScaleController alloc] init];
	}
	
	return scaleController;
}

- (PXCanvasResizePrompter *)resizePrompter
{
	if (!_resizePrompter) {
		_resizePrompter = [[PXCanvasResizePrompter alloc] init];
		_resizePrompter.delegate = self;
		
		[_resizePrompter loadWindow];
	}
	
	return _resizePrompter;
}

- (void)canvasResizePrompter:(PXCanvasResizePrompter *)prompter didFinishWithSize:(NSSize)size
					position:(NSPoint)position backgroundColor:(NSColor *)color
{
	[canvas setSize:size withOrigin:position backgroundColor:PXColorFromNSColor(color)];
	[canvasController updateCanvasSize];
}

- (NSView*)layerSplit;
{
	return layerSplit;
}

- (NSView*)canvasSplit;
{
	return canvasSplit;
}

- (void)awakeFromNib
{
	NSView *paletteView = [paletteController view];
	[paletteSplit addSubview:paletteView];
	[canvasController setLayerController:layerController];
	[layerSplit addSubview:[layerController view]];
	[self updateFrameSizes];
	[self prepareToolbar];
	
	[[self window] setAcceptsMouseMovedEvents:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(draggingOriginChanged:)
												 name:PXDraggingOriginChangedNotificationName
											   object:canvas];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(cursorPositionChanged:)
												 name:PXCursorPositionChangedNotificationName
											   object:canvas];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(canvasColorChanged:)
												 name:PXCanvasColorChangedNotificationName
											   object:canvas];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(canvasNoColorChanged:)
												 name:PXCanvasNoColorChangedNotificationName
											   object:canvas];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PXShowInfoKey]) {
		[self.infoView setHidden:NO];
	}
	else {
		[self.infoView setHidden:YES];
	}
	
	[self setupPropertiesBar];
}

#pragma mark -
#pragma mark Properties Bar

- (void)setupPropertiesBar
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(toolDidChange:)
												 name:PXToolDidChangeNotificationName
											   object:nil];
	
	[[PXToolPaletteController sharedToolPaletteController].leftSwitcher requestToolChangeNotification];
}

- (void)toolDidChange:(NSNotification *)notification
{
	PXToolSwitcher *switcher = [notification object];
	
	if (switcher.tag != self.lrPropertiesSelector.selectedSegment)
		return;
	
	PXTool *tool = [[notification userInfo] objectForKey:PXNewToolKey];
	PXToolPropertiesController *controller = [tool propertiesController];
	
	if (!controller) {
		self.propertiesController = [PXToolPropertiesController new];
	}
	else {
		self.propertiesController = controller;
	}
}

- (void)setPropertiesController:(PXToolPropertiesController *)controller
{
	if (_propertiesController != controller)
	{
		[_propertiesController.view removeFromSuperview];
		
		_propertiesController = controller;
		
		if (controller)
		{
			[self.propertiesBar addSubview:_propertiesController.view];
			[_propertiesController.view setFrameOrigin:NSMakePoint(78.0f, 1.0f)];
		}
	}
}

- (IBAction)changedPropertiesBarDirection:(id)sender
{
	if (self.lrPropertiesSelector.selectedSegment == 0) {
		[[PXToolPaletteController sharedToolPaletteController].leftSwitcher requestToolChangeNotification];
	}
	else {
		[[PXToolPaletteController sharedToolPaletteController].rightSwitcher requestToolChangeNotification];
	}
}

- (IBAction)selectLeftToolProperties:(id)sender
{
	[self.lrPropertiesSelector setSelectedSegment:0];
	[self changedPropertiesBarDirection:nil];
}

- (IBAction)selectRightToolProperties:(id)sender
{
	[self.lrPropertiesSelector setSelectedSegment:1];
	[self changedPropertiesBarDirection:nil];
}

#pragma mark -
#pragma mark Full Screen

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize
{
	proposedSize.width -= 252.0f; // leave some room for the Tools palette
	
	return proposedSize;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
	[[PXToolPaletteController sharedToolPaletteController] enterFullScreenWithDuration:1.0];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
	[[PXToolPaletteController sharedToolPaletteController] exitFullScreenWithDuration:1.0];
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions
{
	return (proposedOptions | NSApplicationPresentationAutoHideToolbar);
}

#pragma mark -

- (void)updateFrameSizes
{
	[[layerController view] setFrameSize:[layerSplit frame].size];
	[[layerController view] setFrameOrigin:NSZeroPoint];

	[[paletteController view] setFrameSize:[paletteSplit frame].size];
	[[paletteController view] setFrameOrigin:NSZeroPoint];
	[[canvasController scrollView] setFrameOrigin:NSMakePoint(0.0f, 26.0f)];
	CGSize size = [[self canvasSplit] frame].size;
	size.height -= 26.0f;
	[[canvasController scrollView] setFrameSize:size];
}

- (void)dealloc
{
	[canvasController deactivate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowWillClose:note
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setCanvas:nil];
	[_gridSettingsController close];
}

- (void)releaseCanvas
{
	canvas = nil;
	[canvasController setCanvas:nil];
}

- (void)setCanvas:(PXCanvas *) aCanvas
{
	if (canvas != aCanvas) {
		canvas = aCanvas;
		[canvasController setCanvas:canvas];
		[paletteController setCanvas:canvas];
	}
}

- (void)setDocument:(PXDocument *)doc
{
	[super setDocument:doc];
	[canvasController setDocument:doc];
}

- (void)windowDidResignMain:note
{
	if ([note object] == [self window])
	{
		[canvasController deactivate];
	}
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	if ([notification object] == [self window])
	{
		[canvasController activate];
		[self updateFrameSizes];
		[self setCanvasSize:[canvas size]];
		
		//FIXME: tight coupling
		if ([self isKindOfClass:[PXAnimationWindowController class]]) {
			[[PXPreviewController sharedPreviewController] setAnimation:[ (PXAnimationWindowController *) self animation]];
		}
		else {
			[[PXPreviewController sharedPreviewController] setSingleCanvas:canvas];
		}
	}
}

- (void)prepare
{
	[canvasController setDocument:[self document]];
	[canvasController setWindow:[self window]];
	[canvasController prepare];
	
	[self zoomToFit:self];
	
	[[self window] useOptimizedDrawing:YES];
}

- (void)updateCanvasSize
{
	[canvasController updateCanvasSize];
}

- (void)flagsChanged:event
{
	[canvasController flagsChanged:event];
}

- (void)rightMouseUp:event
{
	[canvasController rightMouseUp:event];
}

- (void)keyDown:event
{
	if([paletteController isPaletteIndexKey:event])
	{
		[paletteController keyDown:event];
	}
	[canvasController keyDown:event];
}

//- (void)undo:sender { [[[self document] windowController] undo]; }
//- (void)redo:sender { [[[self document] windowController] redo]; }
//- (void)performMiniaturize:sender { [[self window] performMiniaturize:sender]; }
//- (void)toggleToolbarShown:sender { [[self window] toggleToolbarShown:sender]; }
//- (void)runToolbarCustomizationPalette:sender { [[self window] runToolbarCustomizationPalette:sender]; }
//- (void)performClose:sender
//{
//	[window performClose:sender];
//}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {
	return (subview != canvasSplit);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
	if (view == sidebarSplit)
		return NO;
	
	return YES;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin
				 ofSubviewAt:(NSInteger)offset { 
	if(sender == splitView) {
		return 210;
	}
	return 110;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax 
				 ofSubviewAt:(NSInteger)offset {
	if(sender == splitView) {
		return 400;
	}
	return sender.frame.size.height-110;
}


//this is to fix a bug in animation documents where expanding the
//split subview trashes the dimensions of the layer control view
- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	[self updateFrameSizes];
}

@end

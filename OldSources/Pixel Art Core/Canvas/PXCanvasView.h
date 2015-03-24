//
//  PXCanvasView.h
//  Pixen
//

@class PXBackground, PXCanvas, PXCrosshair, PXGrid;

@interface PXCanvasView : NSView 
{
  @private
	PXCrosshair *crosshair;
	NSAffineTransform *transform;
	
	NSBezierPath *cachedMarqueePath;
	NSColor *antsPattern;
	NSTimer *marqueeAnimationTimer;
	NSPoint marqueePatternOffset;
	BOOL drawsSelectionMarquee;
	
	NSPoint centeredPoint;
	BOOL shouldDrawMainBackground;
	BOOL shouldDrawGrid;
	
	BOOL drawsToolBeziers;
	BOOL acceptsFirstMouse;
	
	NSTrackingRectTag trackingRect;
	
	NSPoint lastMousePosition;
	BOOL _usesToolCursors, _updatesInfoBar;
	
	BOOL erasing;
}

@property (nonatomic, weak) PXCanvas *canvas;
@property (nonatomic, assign) int zoomPercentage;

@property (nonatomic, assign) BOOL usesToolCursors;
@property (nonatomic, assign) BOOL updatesInfoBar;

@property (nonatomic, weak) id delegate;

- (void)setCrosshair:aCrosshair;
- (PXCrosshair *)crosshair;
- (id) initWithFrame:(NSRect)rect;

- (NSPoint)convertFromCanvasToViewPoint:(NSPoint)point;
- (NSRect)convertFromCanvasToViewRect:(NSRect)rect;
- (NSPoint)convertFromViewToCanvasPoint:(NSPoint)point;
- (NSPoint)convertFromViewToPartialCanvasPoint:(NSPoint)point;
- (NSPoint)convertFromWindowToCanvasPoint:(NSPoint)location;

- (void)updateMousePosition:(NSPoint)locationInWindow dragging:(BOOL)dragging;

- (void)setShouldDrawSelectionMarquee:(BOOL)drawsSelectionMarquee;
- (void)setNeedsDisplayInCanvasRect:(NSRect)rect;
- (void)sizeToCanvas;
- (void)centerOn:(NSPoint)aPoint;
- (NSAffineTransform *)setupTransform;
- (NSAffineTransform *)setupScaleTransform;
- (NSAffineTransform *)transform;

- (void)panByX:(float)x y:(float)y;

- (void)drawSelectionMarqueeWithRect:(NSRect)rect offset:(NSPoint)off;
- (void)scrollUpBy:(int)amount;
- (void)scrollRightBy:(int)amount;
- (void)scrollDownBy:(int)amount;
- (void)scrollLeftBy:(int)amount;

- (void)setShouldDrawMainBackground:(BOOL)newShouldDraw;
- (void)setShouldDrawGrid:(BOOL)newShouldDraw;
- (PXGrid *)grid;
- (NSRect)convertFromViewToCanvasRect:(NSRect)viewRect;

- (void)setAcceptsFirstMouse:(BOOL)accepts;
- (void)setShouldDrawToolBeziers:(BOOL)newShouldDraw;

- (void)updateCrosshairs:(NSPoint)newLocation;
- (void)updateInfoBarWithMousePosition:(NSPoint)point dragging:(BOOL)dragging;

- (PXBackground *)mainBackground;
- (PXBackground *)alternateBackground;

@end


void PXDebugRect(NSRect r, float alpha);

@interface NSObject (PXCanvasViewDelegate)

- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)eraserDown:(NSEvent *)event;
- (void)eraserUp:(NSEvent *)event;
- (void)eraserDragged:(NSEvent *)event;
- (void)eraserMoved:(NSEvent *)event;

@end

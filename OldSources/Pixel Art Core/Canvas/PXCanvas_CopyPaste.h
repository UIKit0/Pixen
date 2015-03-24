//
//  PXCanvas_CopyPaste.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(CopyPaste)

- (NSInteger)runPasteTooBigAlert:(NSString *)pastedThing size:(NSSize)aSize;
- (BOOL)canContinuePasteOf:(NSString *)pastedThing size:(NSSize)aSize;
- (void)pasteLayer:(PXLayer *)layer;
- (void)pasteLayerFromPasteboard:(NSPasteboard *)board type:(NSString *)type;
- (void)pasteLayerWithImage:(NSImage *)image atIndex:(NSUInteger)index;
- (void)pasteFromPasteboard:(NSPasteboard *)board type:(NSString *)type intoLayer:(PXLayer *)layer;
- (void)pasteFromPasteboard:(NSPasteboard *) board type:(NSString *)type;
- (void)copyLayer:(PXLayer *)layer toPasteboard:(NSPasteboard *)board;
- (void)performCopyMergingLayers:(BOOL)merge;
- (void)copySelection;
- (void)copyMergedSelection;
- (void)cutSelection;
- (void)paste;
- (void)pasteIntoLayer:(PXLayer *)layer;
- (void)cutLayer:(PXLayer *)aLayer;
- (void)copyActiveLayer;
- (void)pasteLayer;

@end

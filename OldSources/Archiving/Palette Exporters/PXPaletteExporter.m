//
//  PXPaletteExporter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteExporter.h"

#import "GPLWriter.h"
#import "OSACTWriter.h"
#import "OSJASCPALWriter.h"
#import "OSPALWriter.h"

@implementation PXPaletteExporter

+ (NSArray *)types
{
	return [NSArray arrayWithObjects:PixenPaletteType, MicrosoftPaletteType, JascPaletteType, AdobePaletteType, GimpPaletteType, nil];
}

- (void)panelDidEndWithReturnCode:(NSInteger)code
{
	if (code == NSFileHandlingPanelCancelButton) {
		[NSApp stopModal];
		return;
	}
	
	NSString *type = [[_typeSelector selectedItem] title];
	
	if ([type isEqualToString:PixenPaletteType]) {
		[NSKeyedArchiver archiveRootObject:[_palette dictForArchiving] toFile:[[_savePanel URL] path]];
	}
	else {
		id writer = nil;
		
		if ([type isEqualToString:MicrosoftPaletteType]) {
			writer = [OSPALWriter sharedPALWriter];
		}
		else if ([type isEqualToString:JascPaletteType]) {
			writer = [OSJASCPALWriter sharedJASCPALWriter];
		}
		else if ([type isEqualToString:AdobePaletteType]) {
			writer = [OSACTWriter sharedACTWriter];
		}
		else if ([type isEqualToString:GimpPaletteType]) {
			writer = [GPLWriter sharedGPLWriter];
		}
		
		if (writer == nil) {
			[NSApp stopModal];
			return;
		}
		
		NSData *data = [writer palDataForPalette:_palette];
		
		if (data == nil) {
			[NSApp stopModal];
			return;
		}
		
		[data writeToURL:[_savePanel URL] atomically:YES];
	}
	
	[NSApp stopModal];
}

- (void)selectedType:(id)sender
{
	NSString *type = [[_typeSelector selectedItem] title];
	NSString *ext = PXPaletteSuffix;
	
	if ([type isEqualToString:MicrosoftPaletteType])
		ext = MicrosoftPaletteSuffix;
	else if ([type isEqualToString:JascPaletteType])
		ext = MicrosoftPaletteSuffix;
	else if ([type isEqualToString:AdobePaletteType])
		ext = AdobePaletteSuffix;
	else if ([type isEqualToString:GimpPaletteType])
		ext = GimpPaletteSuffix;
	
	[_savePanel setAllowedFileTypes:[NSArray arrayWithObject:ext]];
}

- (void)runWithPalette:(PXPalette *)aPalette inWindow:(NSWindow *)window
{
	if (_palette) {
		_palette = nil;
	}
	
	if (aPalette == nil)
		return;
	
	_palette = aPalette;
	
	_savePanel = [NSSavePanel savePanel];
	[_savePanel setAllowedFileTypes:[NSArray arrayWithObjects:PXPaletteSuffix, MicrosoftPaletteSuffix, AdobePaletteSuffix, GimpPaletteSuffix, nil]];
	[_savePanel setPrompt:@"Export"];
	[_savePanel setExtensionHidden:YES];
	[_savePanel setNameFieldStringValue:_palette.name];
	
	_typeSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 250, 40) pullsDown:NO];
	[_typeSelector addItemsWithTitles:[[self class] types]];
	[_typeSelector setTarget:self];
	[_typeSelector setAction:@selector(selectedType:)];
	
	[_savePanel setAccessoryView:_typeSelector];
	
	[self selectedType:_typeSelector];
	
	[_savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
		[self panelDidEndWithReturnCode:result];
	}];
	
	[NSApp runModalForWindow:_savePanel];
	
	_palette = nil;
}

@end

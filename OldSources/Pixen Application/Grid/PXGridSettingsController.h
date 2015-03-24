//
//  PXGridSettingsController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@protocol PXGridSettingsPrompterDelegate;

@interface PXGridSettingsController : NSWindowController

@property (nonatomic, weak) IBOutlet NSColorWell *colorWell;

@property (nonatomic, assign) BOOL showGrid;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) NSColor *color;

@property (nonatomic, unsafe_unretained) id < PXGridSettingsPrompterDelegate > delegate;

- (IBAction)update:(id)sender;
- (IBAction)useAsDefaults:(id)sender;

- (IBAction)dismiss:(id)sender;

- (void)beginSheetWithParentWindow:(NSWindow *)parentWindow;

@end


@protocol PXGridSettingsPrompterDelegate <NSObject>

- (void)gridSettingsController:(PXGridSettingsController *)controller
			   updatedWithSize:(NSSize)size
						 color:(NSColor *)color
					   visible:(BOOL)visible;

@end

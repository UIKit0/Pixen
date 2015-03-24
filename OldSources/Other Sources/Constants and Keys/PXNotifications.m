//
//  PXNotifications.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXNotifications.h"

NSString *PXCanvasLayerSelectionDidChangeNotificationName = @"PXCanvasLayerSelectionDidChange";
NSString *PXCanvasAddedLayerNotificationName = @"PXCanvasAddedLayer";
NSString *PXCanvasRemovedLayerNotificationName = @"PXCanvasRemovedLayer";
NSString *PXCanvasMovedLayerNotificationName = @"PXCanvasMovedLayer";
NSString *PXCanvasSetLayersNotificationName = @"PXCanvasSetLayers";

NSString *PXUpdatedFrequencyPaletteNotificationName = @"PXUpdatedFrequencyPalette";
NSString *PXToggledFrequencyPaletteUpdationNotificationName = @"PXToggledFrequencyPaletteUpdation";

NSString *PXCanvasSizeChangedNotificationName = @"PXCanvasSizeChanged";
NSString *PXCanvasChangedNotificationName = @"PXCanvasChanged";
NSString *PXDraggingOriginChangedNotificationName = @"PXDraggingOriginChanged";
NSString *PXCursorPositionChangedNotificationName = @"PXCursorPositionChanged";
NSString *PXCanvasColorChangedNotificationName = @"PXCanvasColorChanged";
NSString *PXCanvasNoColorChangedNotificationName = @"PXCanvasNoColorChanged";
NSString *PXPatternChangedNotificationName = @"PXPatternChanged";
NSString *PXCanvasSelectionStatusChangedNotificationName = @"PXCanvasSelectionStatusChanged";
NSString *PXToolDidChangeNotificationName = @"PXToolDidChange";
NSString *PXToolColorDidChangeNotificationName = @"PXToolColorDidChange";
NSString *PXToolCursorChangedNotificationName = @"PXToolCursorChanged";
NSString *PXSelectionMaskChangedNotificationName = @"PXSelectionMaskChanged";
NSString *PXBackgroundChangedNotificationName = @"PXBackgroundChanged";
NSString *PXBackgroundTemplateInstalledNotificationName = @"PXBackgroundTemplateInstalled";
NSString *PXUserPalettesChangedNotificationName = @"PXUserPalettesChanged";
NSString *PXPatternsChangedNotificationName = @"PXPatternsChanged";

NSString *PXDocumentOpenedNotificationName = @"PXDocumentOpened";
NSString *PXDocumentWillCloseNotificationName = @"PXDocumentWillClose";
NSString *PXDocumentDidCloseNotificationName = @"PXDocumentDidClose";
NSString *PXDocumentChangedDisplayNameNotificationName = @"PXDocumentChangedDisplayName";

NSString *PXToolDoubleClickedNotificationName = @"PXToolDoubleClicked";

NSString *PXUnlockToolSwitcherNotificationName = @"PXUnlockToolSwitcher";
NSString *PXLockToolSwitcherNotificationName = @"PXLockToolSwitcher";

NSString *PXPresetsChangedNotificationName = @"PXPresetsChanged";

NSString *PXUpdatedHotkeysNotificationName = @"PXUpdatedHotkeys";

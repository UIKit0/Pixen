//
//  PXPresetsManager.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@class PXPreset;

@interface PXPresetsManager : NSObject
{
  @private
	NSMutableArray *_presets;
}

+ (id)sharedPresetsManager;

- (NSArray *)presets;
- (NSArray *)presetNames;

- (PXPreset *)presetWithName:(NSString *)name;

- (void)persistPresets;

- (void)savePresetWithName:(NSString *)name size:(NSSize)size color:(NSColor *)color;
- (void)removePresetWithName:(NSString *)name;

@end

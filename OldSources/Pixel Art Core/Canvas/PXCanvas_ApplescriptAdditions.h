//
//  PXCanvas_ApplescriptAdditions.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvas.h"

@interface PXCanvas (ApplescriptAdditions)

- (id)handleAddLayerScriptCommand:(id)command;
- (id)handleGetColorScriptCommand:(id)command;
- (id)handleMoveLayerScriptCommand:(id)command;
- (id)handleRemoveLayerScriptCommand:(id)command;
- (id)handleSetColorScriptCommand:(id)command;

- (NSString *)activeLayerName;
- (void)setActiveLayerName:(NSString *)name;

- (int)width;
- (int)height;

@end

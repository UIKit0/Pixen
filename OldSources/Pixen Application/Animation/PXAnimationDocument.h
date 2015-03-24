//
//  PXAnimationDocument.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

@class PXAnimation;

@interface PXAnimationDocument : PXDocument
{
  @private
	PXAnimation *_animation;
}

@property (nonatomic, strong, readonly) PXAnimation *animation;

@end

//
//  PXColorArray.h
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXColor.h"

typedef struct PXColorArray *PXColorArrayRef;

typedef void (^PXColorArrayEnumerationBlock)(PXColor);
typedef int(^PXColorComparator)(PXColor *a, PXColor *b);

PXColorArrayRef PXColorArrayCreate(void);

void PXColorArrayRetain(PXColorArrayRef self);
void PXColorArrayRelease(PXColorArrayRef self);

NSUInteger PXColorArrayCount(PXColorArrayRef self);

NSUInteger PXColorArrayIndexOfColor(PXColorArrayRef self, PXColor color);
PXColor PXColorArrayColorAtIndex(PXColorArrayRef self, NSUInteger index);

void PXColorArraySetColorAtIndex(PXColorArrayRef self, NSUInteger index, PXColor color);

void PXColorArrayEnumerateWithBlock(PXColorArrayRef self, PXColorArrayEnumerationBlock block);

void PXColorArrayAppendColor(PXColorArrayRef self, PXColor color);
void PXColorArrayInsertColorAtIndex(PXColorArrayRef self, NSUInteger index, PXColor color);

void PXColorArrayRemoveColorAtIndex(PXColorArrayRef self, NSUInteger index);

void PXColorArrayMoveColor(PXColorArrayRef self, NSUInteger sourceIndex, NSUInteger targetIndex);

void PXColorArraySort(PXColorArrayRef self, PXColorComparator block);

/* behavior is undefined if `index` is out-of-bounds */
NSUInteger PXColorArrayColorInfoAtIndex(PXColorArrayRef self, NSUInteger index);
void PXColorArraySetColorInfoAtIndex(PXColorArrayRef self, NSUInteger index, NSUInteger info);

//
//  OSACTWriter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSACTWriter.h"

@implementation OSACTWriter

- (id)init
{
	[NSException raise:@"SingletonError" format:@"OSACTWriter is a singleton; use sharedACTWriter to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedACTWriter
{
	static OSACTWriter *sharedACTWriter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedACTWriter = [[OSACTWriter alloc] _init];
	});
	
	return sharedACTWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableData *data = [NSMutableData data];
	NSUInteger colorCount = [palette colorCount];
	if (colorCount > 256L)
	{
		NSLog(@"This palette has more than 256 colors, and the ACT format only supports that many; %lu will be truncated.", colorCount-256L);
		colorCount = 256L;
	}
	int i;
	for (i = 0; i < colorCount; i++)
	{
		PXColor color = [palette colorAtIndex:i];
		char colorData[3];
		colorData[0] = color.r;
		colorData[1] = color.g;
		colorData[2] = color.b;
		[data appendBytes:colorData length:3];
	}
	// ACT files must be exactly 768 bytes, so we pad with black.
	for (; i < 256; i++)
	{
		char colorData[3] = {0, 0, 0};
		[data appendBytes:colorData length:3];
	}
	return data;
}

@end

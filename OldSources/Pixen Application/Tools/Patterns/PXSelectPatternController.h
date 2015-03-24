//
//  PXSelectPatternController.h
//  Pixen
//
//  Created by Matt on 2/23/13.
//
//

@class PXPattern;
@protocol PXSelectPatternControllerDelegate;

@interface PXSelectPatternController : NSViewController

@property (nonatomic, weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSTextField *noPatternsLabel;

@property (nonatomic, weak) NSPopover *popover;

@property (nonatomic, unsafe_unretained) id < PXSelectPatternControllerDelegate > delegate;

@end


@protocol PXSelectPatternControllerDelegate

- (void)selectPatternControllerDidChoosePattern:(PXPattern *)pattern;

@end

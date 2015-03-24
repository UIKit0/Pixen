//
//  PXNamePrompter.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

@interface PXNamePrompter : NSWindowController
{
  @private
	BOOL _runningModal;
}

@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSTextField *promptString;

@property (nonatomic, unsafe_unretained) id delegate;

- (void)promptInWindow:(NSWindow *)window;

- (void)promptInWindow:(NSWindow *)window
		  promptString:(NSString *)string defaultEntry:(NSString *)entry;

+ (NSString *)promptModalWithPromptString:(NSString *)string;
- (NSString *)promptModalWithPromptString:(NSString *)string;

- (IBAction)useEnteredName:(id)sender;
- (IBAction)cancel:(id)sender;

@end

//
// Methods Implemented by the Delegate 
//
@interface NSObject(PXNamePrompterDelegate)

// The delegate receives this message when the user hits the button "Use this Name"
- (void)prompter:(id)aPrompter didFinishWithName:(NSString *)aName context:(id)context;

// The delegate receives this message when the user hits the cancel button
- (void)prompter:(id)aPrompter didCancelWithContext:(id)contextObject;

@end

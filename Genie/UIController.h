#import <Cocoa/Cocoa.h>
#import "GHostController.h"

@interface UIController : NSObject {
    IBOutlet id configSelector;
    IBOutlet GHostController *ghostController;
    IBOutlet NSTextView *textEdit;
	IBOutlet id commandLine;
}
- (IBAction)editConfig:(id)sender;
- (IBAction)selectFont:(id)sender;
- (IBAction)processCommand:(id)sender;
@end

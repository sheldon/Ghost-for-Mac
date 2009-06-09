#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"
#import "BadgeView.h"

@interface GHostController : NSObject <TaskWrapperController> {
    IBOutlet id logView;
    IBOutlet id startStopButton;
    IBOutlet id configSelector;
    IBOutlet id badgeView;
	TaskWrapper *ghost;
	BadgeView	*badge;
	NSMutableArray *cfgfiles;
	BOOL isRunning;
}
- (IBAction)startStop:(id)sender;
- (NSString*)getDir;
@end

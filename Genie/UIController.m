#import "UIController.h"

@implementation UIController
- (IBAction)editConfig:(id)sender {
	//NSRunAlertPanel(@"Close Document", 
	//				[[configSelector selectedItem] title],
	//				@"OK", @"Cancel", /*ThirdButtonHere:*/nil
	//				/*, args for a printf-style msg go here */);
	NSString* file = [[ghostController getDir] stringByAppendingPathComponent: [[configSelector selectedItem] title]];
	[textEdit readRTFDFromFile: file];
	/*NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	if (![workspace openFile:file])
		NSRunAlertPanel(@"File Error", 
						@"Could not open config file '%@'\nFile not found or no file handler defined?",
						@"OK", nil,nil,file);*/
    //[NSWorkspace openFile:[[configSelector selectedItem] title]];
}

- (IBAction)selectFont:(id)sender {
    
}
@end

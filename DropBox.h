#import <Cocoa/Cocoa.h>

@protocol DropBoxDragAndDrop
- (BOOL)dropBox:(NSView *)dbv acceptDrop:(id <NSDraggingInfo>)info item:(id)item;
@end

@interface DropBox : NSBox
{
    IBOutlet id <DropBoxDragAndDrop> delegate;
	NSArray *acceptFileTypes;
	NSArray *acceptPathExtensions;
}
@property (retain) NSArray *acceptFileInfo;
@end

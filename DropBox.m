#import "DropBox.h"
#import "PathExtra.h"
#import "HFSTypeUtils.h"

#define useLog 0

@implementation DropBox

- (id)initWithFrame:(NSRect)rect
{
#if useLog
	NSLog(@"initWithFrame DropBox");
#endif	
	self = [super initWithFrame:rect];
    if(self) {
        NSArray* array = [NSArray arrayWithObject:NSFilenamesPboardType];
        [self registerForDraggedTypes:array];
    }
    return self;
}

- (void)awakeFromNib
{
#if useLog
	NSLog(@"awakeFromNib in DropBox");
#endif
	NSArray* array = [NSArray arrayWithObject:NSFilenamesPboardType];
	[self registerForDraggedTypes:array];
}

- (BOOL)shouldAcceptFile:(NSString *)filename
{
	filename = [[filename infoResolvingAliasFile] objectForKey:@"ResolvedPath"];
	NSMutableDictionary *file_info = [[[NSFileManager defaultManager]
						fileAttributesAtPath:filename traverseLink:NO] mutableCopy];
	NSEnumerator *info_enumerator = [acceptFileInfoArray objectEnumerator];
	NSDictionary *a_dict;
	BOOL result = NO;
	while (a_dict = [info_enumerator nextObject] ) {
		BOOL match_to_info = YES;
		//FileType
		NSString *file_type = [a_dict objectForKey:@"FileType"];
		if ( (file_type) &&
				(! [file_type isEqualToString:[file_info objectForKey:NSFileType]]) ) {
			match_to_info = NO;
		}
		
		//isPackage
		if (match_to_info) {
			BOOL is_package = [[a_dict objectForKey:@"isPackage"] boolValue];
			if (is_package) {
				if (![filename isPackage]) {
					match_to_info = NO;
				}
			}
		}
		
		// CreatorCode
		if (match_to_info) {
			NSString *target_creator = [a_dict objectForKey:@"CreatorCode"];
			if (target_creator) {
				NSString *creator;
				if ([[file_info objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
					NSDictionary *bundleinfo = [[NSBundle bundleWithPath:filename] infoDictionary];
					creator = [bundleinfo objectForKey:@"CFBundleSignature"];
				} else {
					creator = OSTypeToNSString([file_info objectForKey:NSFileHFSCreatorCode]);
				}
				if (![target_creator isEqualToString:creator]) {
					match_to_info = NO;
				}
			}
		}
		
		// PathExtension
		if (match_to_info) {
			NSString *an_extension = [a_dict objectForKey:@"PathExtension"];
			if ( (an_extension) &&
					(! [an_extension isEqualToString:[filename pathExtension]]) ) {
				match_to_info = NO;
			}
		}
		
		if (match_to_info) {
			result = YES;
			break;
		}
	}
	
	return result;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
#if useLog
    NSLog(@"draggingEntered: filenames: %@", [filenames description]);
#endif	
    int dragOperation = NSDragOperationNone;
    if ([filenames count] == 1) {
        
        NSEnumerator *filenameEnum = [filenames objectEnumerator]; 
        NSString *filename;
        dragOperation = NSDragOperationCopy;
        while (filename = [filenameEnum nextObject]) {
			if (! [self shouldAcceptFile:filename]) {
				dragOperation = NSDragOperationNone;
				break;			
			}
        }
    }
    return dragOperation;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    BOOL didPerformDragOperation = NO;
#if useLog
    NSLog(@"performDragOperation: filenames: %@", [filenames description]);
#endif	
    if ([filenames count]) {
		didPerformDragOperation = [delegate dropBox:self acceptDrop:sender item:[filenames lastObject]];
    }

    return didPerformDragOperation;
}

#pragma mark Accessors
- (void)setAcceptFileInfo:(NSArray *)fileInfoArray;
{
	[fileInfoArray retain];
	[acceptFileInfoArray release];
	acceptFileInfoArray = fileInfoArray;
}

@end

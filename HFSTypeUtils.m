#import "HFSTypeUtils.h"

NSString *OSTypeToNSString(NSNumber *number)
{
	return (NSString *)CFBridgingRelease(UTCreateStringForOSType([number unsignedIntValue]));
}

NSNumber *StringToOSType(NSString *string)
{
	return [NSNumber numberWithUnsignedLong:UTGetOSTypeFromString((__bridge CFStringRef) string)];
}

@implementation HFSTypeUtils

@end

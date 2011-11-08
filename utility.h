#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#define NSLog(FORMAT, ...) printf("%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
void print_dict(const NSDictionary *map );
void CGImageWriteToFile(CGImageRef image, NSString *path);
CGKeyCode keyCodeForChar(const char c);

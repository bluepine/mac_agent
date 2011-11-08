#import <Cocoa/Cocoa.h>
#define NSLog(FORMAT, ...) printf("%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
void print_dict(const NSDictionary *map );
void CGImageWriteToFile(CGImageRef image, NSString *path);

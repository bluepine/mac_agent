//
//  main.m
//  mac_cmd
//
//  Created by Song Wei on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#define NSLog(FORMAT, ...) printf("%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

NSString *kWindowNameKey = @"kCGWindowName";

void print(const NSDictionary *map ) {
  NSEnumerator *enumerator = [map keyEnumerator];
  id key;
  while ( (key = [enumerator nextObject]) ) {
    id obj = [map objectForKey: key];
    NSLog( @"%@ => %@:%@\n",
	   [key description],
	   [obj description],
	   [[obj class] description]);

  }
}

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);

    bool success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Failed to write image to %@", path);
    }

    CFRelease(destination);
}

int main (int argc, const char * argv[])
{
  id pool=[NSAutoreleasePool new];    
  //    @autoreleasepool {
  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly;//kCGWindowListOptionAll;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
  int arrayCount = CFArrayGetCount(windowList);
  int i;
  for(i=0; i<arrayCount; i++){
    const NSDictionary *entry = (NSDictionary*)CFArrayGetValueAtIndex(windowList, i);
    NSString * wname = [entry objectForKey: kWindowNameKey];
    if(wname &&  (NSOrderedSame==[wname compare: @"EVE Online"])){
      NSLog(@"name: %@\n", wname);
      print(entry);
      CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[entry objectForKey: (id)kCGWindowNumber]unsignedIntValue], kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
      CGImageWriteToFile(windowImage, @"eve.png");
    }
  }
  // insert code here...
  [pool drain];        
  //    }
  return 0;
}


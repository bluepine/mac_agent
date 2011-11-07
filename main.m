/*
 * Copyright (C) 2011 Song Wei
 *
 * Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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


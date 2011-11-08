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

#import "cmds.h"
#import "utility.h"

//parameter: path to store screen shot file
int handle_screenshot(int fd, char * arg){
  NSString *kWindowNameKey = @"kCGWindowName";
  NSString *WindowName = @"EVE Online";
  id pool=[NSAutoreleasePool new];    
  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly;//kCGWindowListOptionAll;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
  int arrayCount = CFArrayGetCount(windowList);
  int i;
  for(i=0; i<arrayCount; i++){
    const NSDictionary *entry = (NSDictionary*)CFArrayGetValueAtIndex(windowList, i);
    NSString * wname = [entry objectForKey: kWindowNameKey];
    if(wname &&  (NSOrderedSame==[wname compare: WindowName])){
      //NSLog(@"name: %@\n", wname);
      //print_dict(entry);
      CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[entry objectForKey: (id)kCGWindowNumber]unsignedIntValue], kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
      CGImageWriteToFile(windowImage, [ NSString stringWithUTF8String:arg ]);
      break;
    }
  }
  [pool drain];
  if(i==arrayCount){
    NSLog(@"window %@ not found!\n", WindowName);
    return -1;
  }else{
    return 0;
  }
}

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

static const NSDictionary * find_eve_window(void){
  const NSDictionary *entry = nil;
  id pool=[NSAutoreleasePool new];
  NSString *kWindowNameKey = @"kCGWindowName";
  NSString *WindowName = @"EVE Online";
  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly;//kCGWindowListOptionAll;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
  int arrayCount = CFArrayGetCount(windowList);
  int i;
  for(i=0; i<arrayCount; i++){
    entry = (NSDictionary*)CFArrayGetValueAtIndex(windowList, i);
    NSString * wname = [entry objectForKey: kWindowNameKey];
    if(wname &&  (NSOrderedSame==[wname compare: WindowName])){
      break;
    }
  }
  if(i==arrayCount){
    entry = nil;
  }
  [pool drain];
  return entry;
}

//parameter: path to store screen shot file
int handle_screenshot(int fd, char * arg){
  id pool=[NSAutoreleasePool new];    

  const NSDictionary *entry = find_eve_window();

  if(entry != nil){
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[entry objectForKey: (id)kCGWindowNumber]unsignedIntValue], kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
    CGImageWriteToFile(windowImage, [ NSString stringWithUTF8String:arg ]);
  }

  [pool drain];
  if(entry == nil){
    NSLog(@"eve window not found!\n");
    return -1;
  }else{
    return 0;
  }
}

int handle_keyevent(int fd, char *arg){
  return 0;
}
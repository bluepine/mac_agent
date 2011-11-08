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

static const NSDictionary * find_window(const char * name){
  const NSDictionary *entry = nil;
  id pool=[NSAutoreleasePool new];
  NSString *kWindowNameKey = @"kCGWindowName";
  NSString *WindowName = [[NSString alloc] initWithUTF8String:name];
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
    NSLog(@"%@ window not found!\n", WindowName);
    entry = nil;
  }
  [pool drain];
  return entry;
}

//parameter: path to store screen shot file
int handle_screenshot(int fd, int argc, const char **argv){
  if(argc != 2){
    return -1;
  }
  id pool=[NSAutoreleasePool new];    

  const NSDictionary *entry = find_window(argv[0]);

  if(entry != nil){
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[entry objectForKey: (id)kCGWindowNumber]unsignedIntValue], kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
    CGImageWriteToFile(windowImage, [ NSString stringWithUTF8String:argv[1] ]);
  }

  [pool drain];
  if(entry == nil){
    return -1;
  }else{
    return 0;
  }
}

struct key_table_entry{
  const char * name;
  CGKeyCode code;
};
static struct key_table_entry special_key_table[] = {
  {"shift", (CGKeyCode)56},
  {"ctrl", (CGKeyCode)59},
  {"cmd", (CGKeyCode)55},
  {"option", (CGKeyCode)58},
  {"enter", (CGKeyCode)76},
  {0, UINT16_MAX}
};

int handle_keyevent(int fd, int argc, const char **argv){
  if(argc != 3){
    return -1;
  }

  id pool=[NSAutoreleasePool new];
  int ret = -1;
  BOOL down = false;
  CGEventRef key_e;
  int i;
  CGKeyCode code;

  const NSDictionary *entry = find_window(argv[0]);
  if(entry == nil){
    goto  handle_keyevent_exit;
  }
  pid_t pid = [[entry objectForKey: @"kCGWindowOwnerPID"] unsignedIntValue];
  ProcessSerialNumber psn;
  if(GetProcessForPID (pid, &psn) < 0){
    goto  handle_keyevent_exit;
  }
  if(!strcmp("down", argv[argc-1])){
    down = true;
  }
  for(i=0; special_key_table[i].name; i++){
    if(!strcmp(special_key_table[i].name, argv[1])){
      code = special_key_table[i].code;
      break;
    }
  }
  if(!special_key_table[i].name){
    code = keyCodeForChar(argv[1][0]);
    if(code == UINT16_MAX){
      goto handle_keyevent_exit;
    }
  }

  key_e = CGEventCreateKeyboardEvent (NULL, code, down);
  CGEventPostToPSN(&psn, key_e);
  ret = 0;
 handle_keyevent_exit:
  [pool drain];
  return ret;
}

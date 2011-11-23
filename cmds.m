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
  {"alt", (CGKeyCode)58},
  {"enter", (CGKeyCode)76},
  {"f1", (CGKeyCode)122},
  {"f2", (CGKeyCode)120},
  {"f3", (CGKeyCode)99},
  {"f4", (CGKeyCode)118},
  {"f5", (CGKeyCode)96},
  {"f6", (CGKeyCode)97},
  {"f7", (CGKeyCode)98},
  {"f8", (CGKeyCode)100},
  {0, UINT16_MAX}
};

struct modifier_table_entry{
  const char * name;
  const CGEventFlags mask;
  int active;
};

static struct modifier_table_entry modifier_table[] = {
  {"shift", kCGEventFlagMaskShift, 0},
  {"ctrl", kCGEventFlagMaskControl, 0},
  {"alt", kCGEventFlagMaskAlternate, 0},
  {"cmd", kCGEventFlagMaskCommand, 0},
  {0, 0}
};

int handle_key_event(int fd, int argc, const char **argv){
  if(argc != 3){
    return -1;
  }
  int modifier = 0;
  id pool=[NSAutoreleasePool new];
  int ret = -1;
  BOOL down = false;
  CGEventRef key_e;
  int i;
  CGKeyCode code;

  const NSDictionary *entry = find_window(argv[0]);
  if(entry == nil){
    goto  handle_key_event_exit;
  }
  pid_t pid = [[entry objectForKey: @"kCGWindowOwnerPID"] unsignedIntValue];
  ProcessSerialNumber psn;
  if(GetProcessForPID (pid, &psn) < 0){
    goto  handle_key_event_exit;
  }
  if(!strcmp("down", argv[argc-1])){
    down = true;
  }
  for(i=0; modifier_table[i].name; i++){
    if(!strcmp(modifier_table[i].name, argv[1])){
      modifier = 1;
      if(down){
	modifier_table[i].active = 1;
      }else{
	modifier_table[i].active = 0;
      }
    }
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
      goto handle_key_event_exit;
    }
  }

  key_e = CGEventCreateKeyboardEvent (NULL, code, down);
  if(key_e == NULL){
    goto handle_key_event_exit;
  }
  if(!modifier){
    for(i=0; modifier_table[i].name; i++){
      if(modifier_table[i].active){
	CGEventSetFlags(key_e, modifier_table[i].mask);      
      }
    }
  }
  NSLog(@"%d, %d\n", code, down);
  Boolean result;
  ProcessSerialNumber front_psn;
  GetFrontProcess(&front_psn);
  SameProcess(&front_psn, &psn, &result);
  if(!result){
    if(SetFrontProcess(&psn)){
      goto  handle_key_event_exit;
    }
    sleep(2);
  }
  CGEventPostToPSN(&psn, key_e);
  usleep(20000);
  ret = 0;
 handle_key_event_exit:
  [pool drain];
  return ret;
}

//mouse down, up, move, drag
//window name,left/right,down/up/move/drag,x,y
int handle_mouse_event(int fd, int argc, const char **argv){
  if(argc!=5){
    return -1;
  }
  id pool=[NSAutoreleasePool new];
  int ret = -1;
  const NSDictionary *entry = find_window(argv[0]);
  if(entry == nil){
    goto  handle_mouse_event_exit;
  }
  pid_t pid = [[entry objectForKey: @"kCGWindowOwnerPID"] unsignedIntValue];
  ProcessSerialNumber psn;
  if(GetProcessForPID (pid, &psn) < 0){
    goto  handle_mouse_event_exit;
  }
  const NSDictionary *bound = [entry objectForKey: @"kCGWindowBounds"];
  if(bound == nil){
    goto  handle_mouse_event_exit;
  }

  CGEventType mouseType;
  CGPoint mouseCursorPosition;
  CGMouseButton mouseButton;
  
  if(!strcmp(argv[1], "left")){
    mouseButton = kCGMouseButtonLeft;
  }else if(!strcmp(argv[1], "right")){
    mouseButton = kCGMouseButtonRight;
  }else{
    goto handle_mouse_event_exit;
  }

  if(!strcmp(argv[2], "down")){
    mouseType = kCGEventOtherMouseDown;
  }else if(!strcmp(argv[2], "up")){
    mouseType = kCGEventOtherMouseUp;
  }else if(!strcmp(argv[2], "drag")){
    mouseType = kCGEventOtherMouseDragged;
  }else if(!strcmp(argv[2], "move")){
    mouseType = kCGEventMouseMoved;
  }else{
    goto handle_mouse_event_exit;
  }
  
  mouseCursorPosition.x = (CGFloat)atoi(argv[3])+(CGFloat)[[bound objectForKey: @"X"] floatValue];
  mouseCursorPosition.y = (CGFloat)atoi(argv[4])+(CGFloat)[[bound objectForKey: @"Y"] floatValue];
  //NSLog(@"%d, %f, %f\n", mouseType, (double)(mouseCursorPosition.x), (double)(mouseCursorPosition.y));
  CGEventRef m_e = CGEventCreateMouseEvent(NULL, mouseType, mouseCursorPosition, mouseButton);
  if(m_e == NULL){
    goto  handle_mouse_event_exit;
  }
  Boolean result;
  ProcessSerialNumber front_psn;
  GetFrontProcess(&front_psn);
  SameProcess(&front_psn, &psn, &result);
  if(!result){
    if(SetFrontProcess(&psn)){
      goto  handle_mouse_event_exit;
    }
    sleep(2);
  }
  //CGEventPostToPSN(&psn, m_e);//why is this not working?
  CGEventPost(kCGHIDEventTap, m_e);
  usleep(20000);
  //sleep(2);
  ret = 0;  
 handle_mouse_event_exit:
  [pool drain];
  return ret;
}

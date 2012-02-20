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

static const NSDictionary * find_window(const NSString *WindowName){
  const NSDictionary *entry = nil;
  id pool=[NSAutoreleasePool new];
  NSString *kWindowNameKey = @"kCGWindowName";
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
int handle_screenshot_cmd_cocoa(const NSString *WindowName, const NSString *screenshot_path){

  id pool=[NSAutoreleasePool new];    

  const NSDictionary *entry = find_window(WindowName);

  if(entry != nil){
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[entry objectForKey: (id)kCGWindowNumber]unsignedIntValue], kCGWindowImageDefault | kCGWindowImageBoundsIgnoreFraming);
    CGImageWriteToFile(windowImage, screenshot_path);
  }

  [pool drain];
  if(entry == nil){
    return -1;
  }else{
    return 0;
  }
}

struct key_table_entry{
  NSString * name;
  CGKeyCode code;
};
static struct key_table_entry special_key_table[] = {
  {@"shift", (CGKeyCode)56},
  {@"ctrl", (CGKeyCode)59},
  {@"cmd", (CGKeyCode)55},
  {@"alt", (CGKeyCode)58},
  {@"enter", (CGKeyCode)76},
  {@"f1", (CGKeyCode)122},
  {@"f2", (CGKeyCode)120},
  {@"f3", (CGKeyCode)99},
  {@"f4", (CGKeyCode)118},
  {@"f5", (CGKeyCode)96},
  {@"f6", (CGKeyCode)97},
  {@"f7", (CGKeyCode)98},
  {@"f8", (CGKeyCode)100},
  {NULL, UINT16_MAX}
};

struct modifier_table_entry{
  NSString * name;
  const CGEventFlags mask;
  int active;
};

static struct modifier_table_entry modifier_table[] = {
  {@"shift", kCGEventFlagMaskShift, 0},
  {@"ctrl", kCGEventFlagMaskControl, 0},
  {@"alt", kCGEventFlagMaskAlternate, 0},
  {@"cmd", kCGEventFlagMaskCommand, 0},
  {NULL, 0}
};

int handle_key_cmd_cocoa(const NSString *WindowName, const NSString *key, const key_event::type event){
  int modifier = 0;
  id pool=[NSAutoreleasePool new];
  int ret = -1;
  CGEventRef key_e;
  int i;
  CGKeyCode code;
  pid_t pid = 0;
  const NSDictionary *entry = find_window(WindowName);
  if(entry == nil){
    goto  handle_key_event_exit;
  }
  pid = [[entry objectForKey: @"kCGWindowOwnerPID"] unsignedIntValue];
  ProcessSerialNumber psn;
  if(GetProcessForPID (pid, &psn) < 0){
    goto  handle_key_event_exit;
  }
  for(i=0; modifier_table[i].name; i++){
    if([modifier_table[i].name isEqualToString: key]){
      modifier = 1;
      if(key_event::KeyDown == event){
	modifier_table[i].active = 1;
      }else{
	modifier_table[i].active = 0;
      }
    }
  }
  for(i=0; special_key_table[i].name; i++){
    if([special_key_table[i].name isEqualToString: key]){
      code = special_key_table[i].code;
      break;
    }
  }
  if(!special_key_table[i].name){
    code = keyCodeForChar([key characterAtIndex: 0]);
    if(code == UINT16_MAX){
      goto handle_key_event_exit;
    }
  }

  key_e = CGEventCreateKeyboardEvent (NULL, code, (key_event::KeyDown == event));
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
  NSLog(@"%d, %d\n", code, (key_event::KeyDown == event));
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
int handle_mouse_cmd_cocoa(const NSString *WindowName, const mouse_button::type button, const mouse_event::type event, const int32_t x, const int32_t y){
  CGEventRef m_e = NULL;
  const NSDictionary *bound = NULL;
  ProcessSerialNumber psn;
  pid_t pid = 0;
  int ret = -1;
  id pool=[NSAutoreleasePool new];

  const NSDictionary *entry = find_window(WindowName);
  if(entry == nil){
    goto  handle_mouse_event_exit;
  }
  pid = [[entry objectForKey: @"kCGWindowOwnerPID"] unsignedIntValue];

  if(GetProcessForPID (pid, &psn) < 0){
    goto  handle_mouse_event_exit;
  }
  bound = [entry objectForKey: @"kCGWindowBounds"];
  if(bound == nil){
    goto  handle_mouse_event_exit;
  }

  CGEventType mouseType;
  CGPoint mouseCursorPosition;
  CGMouseButton mouseButton;
  
  if(mouse_button::MouseButtonLeft == button){
    mouseButton = kCGMouseButtonLeft;
  }else if(mouse_button::MouseButtonRight == button){
    mouseButton = kCGMouseButtonRight;
  }else{
    goto handle_mouse_event_exit;
  }

  if(mouse_event::MouseDown == event){
    mouseType = kCGEventOtherMouseDown;
  }else if(mouse_event::MouseUp == event){
    mouseType = kCGEventOtherMouseUp;
  }else if(mouse_event::MouseDragged == event){
    mouseType = kCGEventOtherMouseDragged;
  }else if(mouse_event::MouseMoved == event){
    mouseType = kCGEventMouseMoved;
  }else{
    goto handle_mouse_event_exit;
  }
  
  mouseCursorPosition.x = (CGFloat)x+(CGFloat)[[bound objectForKey: @"X"] floatValue];
  mouseCursorPosition.y = (CGFloat)y+(CGFloat)[[bound objectForKey: @"Y"] floatValue];
  //NSLog(@"%d, %f, %f\n", mouseType, (double)(mouseCursorPosition.x), (double)(mouseCursorPosition.y));
  m_e = CGEventCreateMouseEvent(NULL, mouseType, mouseCursorPosition, mouseButton);
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

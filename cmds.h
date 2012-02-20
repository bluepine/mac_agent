#import <Cocoa/Cocoa.h>
#include "mac_agent.h"
int handle_screenshot_cmd_cocoa(const NSString *WindowName, const NSString *screenshot_path);
int handle_key_cmd_cocoa(const NSString *WindowName, const NSString *ns_key, const key_event::type event);
int handle_mouse_cmd_cocoa(const NSString *WindowName, const mouse_button::type button, const mouse_event::type event, const int32_t x, const int32_t y);

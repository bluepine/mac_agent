#import <Cocoa/Cocoa.h>
#include "mac_agent.h"
int screenshot_cmd(NSString *WindowName);
int key_cmd(NSString *WindowName, NSString *ns_key, const key_event::type event);
int handle_mouse_event(int fd, int argc, const char **argv);

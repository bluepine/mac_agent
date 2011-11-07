//
//  main.m
//  mac_cmd
//
//  Created by Song Wei on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#pragma mark Window List & Window Image Methods
typedef struct
{
  // Where to add window information
  NSMutableArray * outputArray;
  // Tracks the index of the window when first inserted
  // so that we can always request that the windows be drawn in order.
  int order;
} WindowListApplierData;

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowOriginKey = @"windowOrigin";	// Window Origin as a string
NSString *kWindowSizeKey = @"windowSize";		// Window Size as a string
NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
  NSDictionary *entry = (NSDictionary*)inputDictionary;
  WindowListApplierData *data = (WindowListApplierData*)context;
	
  // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
  // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
  int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
  if(sharingState != kCGWindowSharingNone)
    {
      NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
		
      // Grab the application name, but since it's optional we need to check before we can use it.
      NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
      if(applicationName != NULL)
	{
	  // PID is required so we assume it's present.
	  NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, [entry objectForKey:(id)kCGWindowOwnerPID]];
	  [outputEntry setObject:nameAndPID forKey:kAppNameKey];
	}
      else
	{
	  // The application name was not provided, so we use a fake application name to designate this.
	  // PID is required so we assume it's present.
	  NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", [entry objectForKey:(id)kCGWindowOwnerPID]];
	  [outputEntry setObject:nameAndPID forKey:kAppNameKey];
	}
      NSLog(@"%@", applicationName);
      // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
      CGRect bounds;
      CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
      NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
      [outputEntry setObject:originString forKey:kWindowOriginKey];
      NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
      [outputEntry setObject:sizeString forKey:kWindowSizeKey];
      NSLog(@"%@", sizeString);
      // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
      [outputEntry setObject:[entry objectForKey:(id)kCGWindowNumber] forKey:kWindowIDKey];
      [outputEntry setObject:[entry objectForKey:(id)kCGWindowLayer] forKey:kWindowLevelKey];
		
      // Finally, we are passed the windows in order from front to back by the window server
      // Should the user sort the window list we want to retain that order so that screen shots
      // look correct no matter what selection they make, or what order the items are in. We do this
      // by maintaining a window order key that we'll apply later.
      [outputEntry setObject:[NSNumber numberWithInt:data->order] forKey:kWindowOrderKey];
      data->order++;
		
      [data->outputArray addObject:outputEntry];
    }
}

int main (int argc, const char * argv[])
{
  id pool=[NSAutoreleasePool new];    
  //    @autoreleasepool {
  CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly;//kCGWindowListOptionAll;
  CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
  NSMutableArray * prunedWindowList = [NSMutableArray array];
  WindowListApplierData data = {prunedWindowList, 0};
  CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
        
  // insert code here...
  NSLog(@"Hello, World!");
  [pool drain];        
  //    }
  return 0;
}


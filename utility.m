#import "utility.h"

void print_dict(const NSDictionary *map ) {
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

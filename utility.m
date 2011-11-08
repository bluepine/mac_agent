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

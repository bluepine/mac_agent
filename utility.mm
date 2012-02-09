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

static CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
      (CFDataRef) TISGetInputSourceProperty(currentKeyboard,
                                  kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
        (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;

    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);    

    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;

    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;

        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }

    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);

    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }

    CFRelease(charStr);
    return code;
}

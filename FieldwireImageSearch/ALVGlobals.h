//
//  ALVGlobals.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALVGlobals : NSObject

+ (NSNumber *)statusBarHeight;

@end


// Screen Sizing Macros
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

// Device Orientation Macros
#define IS_PORTRAIT ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)
#define IS_LANDSCAPE ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) || ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft)
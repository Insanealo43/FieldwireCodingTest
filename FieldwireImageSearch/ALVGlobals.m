//
//  ALVGlobals.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVGlobals.h"
#import "AppDelegate.h"

@implementation ALVGlobals

+ (NSNumber *)statusBarHeight {
    return @([UIApplication sharedApplication].statusBarFrame.size.height);
}

@end


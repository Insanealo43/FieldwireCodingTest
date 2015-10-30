//
//  NSObject+ALVAdditions.m
//  ALVCustomViews
//
//  Created by Andrew Lopez-Vass on 10/28/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "NSObject+ALVAdditions.h"
#import <objc/runtime.h>

/*
 The key we are using for our associated object is a pointer of type static const void *. We have to initialise this pointer with something, otherwise its value will be NULL (making it useless as a key), but we don’t care what value it points to, so long as it’s unique. To avoid allocating any unnecessary additional memory, we’ve set it to point to itself! The value of the pointer is now the same as the address of the pointer, which is unique (because it’s static), and won’t change (because it’s const).
 */
static const void *RestorationIdKey = &RestorationIdKey;

@implementation NSObject (ALVAdditions)

+ (NSString *)className {
    return NSStringFromClass([self class]);
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

- (NSString *)restorationIdentifier {
    /*
     Objective-C selectors (method names) are actually constant pointers. This means that they are suitable to be used as keys for associated objects.
     
        Use '@selector(@{propertyName})' as key.
     */
    return objc_getAssociatedObject(self, RestorationIdKey);
}

/*
 We’re using OBJC_ASSOCIATION_COPY_NONATOMIC as the association policy. This matches the attributes of the tag property we declared in the category header. We’re using nonatomic because this is a UIKit class and we’re assuming it will only be accessed on the main thread. We’re using copy because this is always best practice when dealing with strings, or any other type that has mutable subclasses (to ensure that the value we store is actually an NSString and not an NSMutableString).
 */
- (void)setRestorationIdentifier:(NSString *)restorationIdentifier {
    objc_setAssociatedObject(self, RestorationIdKey, restorationIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

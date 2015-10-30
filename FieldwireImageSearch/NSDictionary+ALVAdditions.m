//
//  NSDictionary+ALVAdditions.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "NSDictionary+ALVAdditions.h"

@implementation NSDictionary (ALVAdditions)

- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if ([object isEqual:[NSNull null]])
        return nil;
    
    return object;
}

@end

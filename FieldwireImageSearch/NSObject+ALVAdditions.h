//
//  NSObject+ALVAdditions.h
//  ALVCustomViews
//
//  Created by Andrew Lopez-Vass on 10/28/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ALVAdditions)

+ (NSString *)className;
- (NSString *)className;

// Associated Objects
@property (nonatomic, copy) NSString *restorationIdentifier;

@end

//
//  UIView+ALVAdditions.m
//  ALVCustomViews
//
//  Created by Andrew Lopez-Vass on 10/28/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "UIView+ALVAdditions.h"
#import "NSObject+ALVAdditions.h"

static NSString *const kNib = @"nib";

@implementation UIView (ALVAdditions)

- (UIView *)viewFromNib {
    // Check to see if .xib file exists before loading it
    if ([[NSBundle mainBundle] pathForResource:[self className] ofType:kNib] != nil) {
        // Load from bundle and return the first view found
        return [[[NSBundle mainBundle] loadNibNamed:[self className] owner:self options:nil] firstObject];
    }
    
    return nil;
}

- (CGRect)frameWithX:(CGFloat)x {
    return CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGRect)frameWithY:(CGFloat)y {
    return CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGRect)frameWithWidth:(CGFloat)w {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, w, self.frame.size.height);
}

- (CGRect)frameWithHeight:(CGFloat)h {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
}

- (CGSize)sizeWithWidht:(CGFloat)w {
    return CGSizeMake(w, self.frame.size.height);
}

- (CGSize)sizeWithHeight:(CGFloat)h {
    return CGSizeMake(self.frame.size.width, h);
}

- (CGPoint)pointWithX:(CGFloat)x {
    return CGPointMake(x, self.frame.origin.y);
}

- (CGPoint)pointWithY:(CGFloat)y {
    return CGPointMake(self.frame.origin.x, y);
}

@end

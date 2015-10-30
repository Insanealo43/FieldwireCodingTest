//
//  UIView+ALVAdditions.h
//  ALVCustomViews
//
//  Created by Andrew Lopez-Vass on 10/28/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ALVAdditions)

- (UIView *)viewFromNib;

- (CGRect)frameWithX:(CGFloat)x;
- (CGRect)frameWithY:(CGFloat)y;
- (CGRect)frameWithWidth:(CGFloat)w;
- (CGRect)frameWithHeight:(CGFloat)h;

- (CGSize)sizeWithWidht:(CGFloat)w;
- (CGSize)sizeWithHeight:(CGFloat)h;

- (CGPoint)pointWithX:(CGFloat)x;
- (CGPoint)pointWithY:(CGFloat)y;

@end

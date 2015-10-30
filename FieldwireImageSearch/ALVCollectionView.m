//
//  ALVCollectionView.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVCollectionView.h"

static const CGFloat kSpinnerDefaultDimension = 80;

@interface ALVCollectionView ()

@end

@implementation ALVCollectionView

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kSpinnerDefaultDimension, kSpinnerDefaultDimension)];
        spinner.color = [UIColor grayColor];
        
        _spinner = spinner;
    }
    return _spinner;
}

- (BOOL)isAnimating {
    return [[self.spinner superview] isEqual:self];
}

- (void)animateSpinner:(BOOL)animate {
    [self.spinner removeFromSuperview];
    
    if (animate) {
        // Start animating
        [self.spinner startAnimating];
        [self addSubview:self.spinner];
        
    } else if (!animate) {
        // Stop animating
        [self.spinner stopAnimating];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    [self.spinner setFrame:CGRectMake(center.x - kSpinnerDefaultDimension/2.0, center.y - kSpinnerDefaultDimension/2.0, kSpinnerDefaultDimension, kSpinnerDefaultDimension)];
}

@end

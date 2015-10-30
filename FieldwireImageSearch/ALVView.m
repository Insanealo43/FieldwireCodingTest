//
//  ALVView.m
//  ALVCustomViews
//
//  Created by Andrew Lopez-Vass on 10/28/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVView.h"
#import "NSObject+ALVAdditions.h"
#import "UIView+ALVAdditions.h"

@interface ALVView() {
    CGSize _intrinsicContentSize;
}
@end

@implementation ALVView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Frame needs to be set programmatically
        
        // 1. Load .xib
        UIView *view = [self viewFromNib];
        CGRect viewBounds = view.bounds;
        
        // 2. Adjust the bounds
        self.bounds = viewBounds;
        
        // 3. Retain the instrinsize size
        _intrinsicContentSize = viewBounds.size;
        
        // 4. Add as a subview
        [self addSubview:view];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Frame is automatically set for us from our .xib file
        
        // 1. Load interface file from .xib
        UIView *view = [self viewFromNib];
        
        // 2. Add as a subview
        [self addSubview:view];
        
        // 3. Retain the instrinsize size
        _intrinsicContentSize = self.frame.size;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return _intrinsicContentSize;
}

@end

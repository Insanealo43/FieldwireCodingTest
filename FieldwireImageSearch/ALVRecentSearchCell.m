//
//  ALVRecentSearchCell.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/30/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVRecentSearchCell.h"

const CGFloat kRecentSearchCellDefaultHeight = 32;

@implementation ALVRecentSearchCell

- (UILabel *)recentSearchLabel {
    if (!_recentSearchLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:24]];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        _recentSearchLabel = label;
    }
    
    return _recentSearchLabel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell {
    [self.contentView addSubview:self.recentSearchLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.recentSearchLabel setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [self setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.2]];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^() {
            [self setBackgroundColor:[UIColor clearColor]];
            
        } completion:nil];
    }
}

@end

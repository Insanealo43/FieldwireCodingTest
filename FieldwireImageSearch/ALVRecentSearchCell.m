//
//  ALVRecentSearchCell.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/30/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVRecentSearchCell.h"

const CGFloat kRecentSearchCellDefaultHeight = 30;

static const CGFloat kLabelLeftInset = 15;
static const CGFloat kSearchIconInset = 15;
static const CGFloat kPadding = 10;
static NSString *const kLabelTextKeyPath = @"text";

@interface ALVRecentSearchCell ()

@property (strong, nonatomic) UIImageView *searchIcon;

@end

@implementation ALVRecentSearchCell

- (UILabel *)recentSearchLabel {
    if (!_recentSearchLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:24]];
        [label setTextAlignment:NSTextAlignmentLeft];
        
        _recentSearchLabel = label;
    }
    
    return _recentSearchLabel;
}

- (UIImageView *)searchIcon {
    if (!_searchIcon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIconTransparent"]];
        [imageView setClipsToBounds:YES];
        
        _searchIcon = imageView;
    }
    return _searchIcon;
}

- (void)dealloc {
    [self.recentSearchLabel removeObserver:self forKeyPath:kLabelTextKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isEqual:self.recentSearchLabel]) {
        if ([keyPath isEqualToString:kLabelTextKeyPath]) {
            // Update label size
            [self layoutSubviews];
        }
    }
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
    [self.contentView addSubview:self.searchIcon];
    
    [self.recentSearchLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat xOffset = kLabelLeftInset;
    [self.searchIcon setFrame:CGRectMake(xOffset, 0, self.frame.size.height, self.frame.size.height)];
    xOffset += self.searchIcon.frame.size.width + kPadding;
    
    [self.recentSearchLabel setFrame:CGRectMake(xOffset, 0, self.frame.size.width - xOffset, self.frame.size.height)];
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

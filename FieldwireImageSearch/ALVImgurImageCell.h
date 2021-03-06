//
//  ALVImgurImageCell.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kImageCellDefaultWidth;
extern const CGFloat kImageCellDefaultHeight;

@class ALVImgurImage;
@interface ALVImgurImageCell : UICollectionViewCell

+ (CGSize)cellSize;

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) ALVImgurImage *imageData;

- (void)animteLoading:(BOOL)animate;
- (void)fadeImageIn;
- (void)fadeImageOut;

@end

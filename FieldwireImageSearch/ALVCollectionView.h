//
//  ALVCollectionView.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALVCollectionView : UICollectionView

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (readonly) BOOL isAnimating;

- (void)animateSpinner:(BOOL)animate;

@end

//
//  ALVSearchBar.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALVSearchBarDelegate;
@interface ALVSearchBar : UISearchBar

@property (strong, nonatomic) UIToolbar *dimissalToolbar;
@property (assign, nonatomic) NSTimeInterval triggerDuration;
@property (assign, nonatomic, readonly) BOOL isSearching;

- (UITextField *)textField;

- (id<ALVSearchBarDelegate>)delegate;
- (void)setDelegate:(id<ALVSearchBarDelegate>)delegate;

+ (instancetype)searchBarWithDelegate:(id<ALVSearchBarDelegate>)delegate;
- (instancetype)initWithDelegate:(id<ALVSearchBarDelegate>)delegate;
- (void)configure;

@end

@protocol ALVSearchBarDelegate <UISearchBarDelegate>

@optional
- (void)searchBar:(ALVSearchBar *)searchBar timedTriggeredTextChange:(NSString *)searchText;

@end
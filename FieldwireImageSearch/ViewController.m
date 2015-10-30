//
//  ViewController.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ViewController.h"

/* TODO: Move to Prefix file */
#import "ALVGlobals.h"
#import "ALVNetworkInterface.h"
#import "NSObject+ALVAdditions.h"

#import <AFNetworking/AFNetworking.h>
#import <ImgurSession/ImgurSession.h>
#import "MWPhotoBrowser+ALVAdditions.h"

#import "ALVImageManager.h"
#import "ALVSearchBar.h"
#import "ALVCollectionView.h"
#import "ALVImgurImage.h"
#import "ALVImgurImageCell.h"
#import "ALVRecentSearchCell.h"

static const CGFloat kCellSpacing = 10;
static const CGFloat kPagingLoadHeight = 40;
static const CGFloat kContentHeightMultiplier = 1.75;

static const NSUInteger kMaxNumberSavedPreviousSearches = 10;
static const CGFloat kRecentSearchLabelHeight = 52;

@interface ViewController () <ALVSearchBarDelegate, IMGSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate>

@property (strong, nonatomic) ALVSearchBar *customSearchBar;
@property (strong, nonatomic) ALVCollectionView *imageCollection;
@property (strong, nonatomic) UICollectionView *searchesCollection;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) UILabel *recentSearchLabel;

@property (strong, nonatomic) NSMutableArray *imgurImages;
@property (strong, nonatomic) NSMutableArray *browserPhotos;
@property (strong, nonatomic) NSMutableArray *recentSearches;

@property (strong, nonatomic) NSNumber *pageNum;
@property (assign, nonatomic) BOOL isFetchingPage;

@end

@implementation ViewController

- (ALVCollectionView *)imageCollection {
    if (!_imageCollection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setMinimumInteritemSpacing:0.0];
        [flowLayout setMinimumLineSpacing:kCellSpacing];
        
        ALVCollectionView *collectionView = [[ALVCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [collectionView setBackgroundColor:[UIColor whiteColor]];
        [collectionView setAlwaysBounceVertical:YES];
        [collectionView setContentInset:UIEdgeInsetsMake(0, kCellSpacing, kCellSpacing, kCellSpacing)];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        
        // Register cells
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:[UICollectionViewCell className]];
        [collectionView registerClass:[ALVImgurImageCell class] forCellWithReuseIdentifier:[ALVImgurImageCell className]];
        [collectionView registerClass:[ALVRecentSearchCell class] forCellWithReuseIdentifier:[ALVRecentSearchCell className]];
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[UICollectionReusableView className]];
        
        _imageCollection = collectionView;
    }
    return _imageCollection;
}

- (UICollectionView *)searchesCollection {
    if (!_searchesCollection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [flowLayout setMinimumInteritemSpacing:0.0];
        [flowLayout setMinimumLineSpacing:0.0];
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [collectionView setBackgroundColor:[UIColor whiteColor]];
        [collectionView setAlwaysBounceVertical:NO];
        [collectionView setContentInset:UIEdgeInsetsMake(0, kCellSpacing, kCellSpacing, kCellSpacing)];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        
        // Register cells
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:[UICollectionViewCell className]];
        [collectionView registerClass:[ALVRecentSearchCell class] forCellWithReuseIdentifier:[ALVRecentSearchCell className]];
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[UICollectionReusableView className]];
         
         _searchesCollection = collectionView;
    }
    
    return _searchesCollection;
}

- (ALVSearchBar *)customSearchBar {
    if (!_customSearchBar) {
        ALVSearchBar *searchBar = [[ALVSearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        searchBar.delegate = self;
        
        _customSearchBar = searchBar;
    }
    return _customSearchBar;
}

- (UIActivityIndicatorView *)loadingSpinner {
    if (!_loadingSpinner) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
        spinner.color = [UIColor grayColor];
        
        _loadingSpinner = spinner;
    }
    return _loadingSpinner;
}

- (UILabel *)recentSearchLabel {
    if (!_recentSearchLabel) {
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont systemFontOfSize:36]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setText:@"Recent Searches"];
        
        _recentSearchLabel = label;
    }
    return _recentSearchLabel;
}

- (NSMutableArray *)recentSearches {
    if (!_recentSearches) {
        _recentSearches = [NSMutableArray new];
    }
    return _recentSearches;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.customSearchBar];
    [self.view addSubview:self.imageCollection];
    [self.view addSubview:self.searchesCollection];
    
    [self.imageCollection setHidden:YES];
    
    // Setup notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailImageFetchedNotification:) name:kFetchedThumbnailImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardDidShowNotification object:nil];
    
    // Load Recent Searches from User Default
    NSString *classRecentSearchesKey = [NSString stringWithFormat:@"%@.recentSearches", [self className]];
    NSArray *recentSearches = [[NSUserDefaults standardUserDefaults] objectForKey:classRecentSearchesKey];
    self.recentSearches = [NSMutableArray arrayWithArray:recentSearches];
    
    // Launch the keyboard if no searches
    if ([self.recentSearches count] == 0) {
        [self.customSearchBar becomeFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.frame = [[UIScreen mainScreen] bounds];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat yOffset = [[ALVGlobals statusBarHeight] floatValue];
    [self.customSearchBar setFrame:CGRectMake(0, yOffset, SCREEN_WIDTH, 34)];
    
    yOffset += self.customSearchBar.frame.size.height;
    [self.imageCollection setFrame:CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset)];
    [self.searchesCollection setFrame:self.imageCollection.frame];
    
    [self.loadingSpinner setFrame:CGRectMake(0, 0, self.view.frame.size.width, kPagingLoadHeight)];
    
    CGFloat width = self.imageCollection.frame.size.width - 2*kCellSpacing;
    [self.recentSearchLabel setFrame:CGRectMake(0, 0, width, kRecentSearchLabelHeight)];
}

#pragma mark - NSNotification Callbacks
- (void)thumbnailImageFetchedNotification:(NSNotification *)notification {
    if (notification.object) {
        // Check if the image needs to be updated in this controller
        if ([self.imgurImages containsObject:notification.object]) {
            ALVImgurImage *imgurImage = notification.object;
            NSIndexPath *imageIndexPath = [self indexPathForImgurImage:imgurImage];
            
            // Reconfigure the cell
            if (imageIndexPath) {
                ALVImgurImageCell *imageCell = (id)[self.imageCollection cellForItemAtIndexPath:imageIndexPath];
                [imageCell setImageData:imgurImage];
            }
        }
    }
}

- (void)keyboardAppeared:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //[self.imageCollection setContentInset:UIEdgeInsetsMake(0, kCellSpacing, kCellSpacing + keyboardRect.size.height, kCellSpacing)];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //[self.imageCollection setContentInset:UIEdgeInsetsMake(0, kCellSpacing, kCellSpacing + keyboardRect.size.height, kCellSpacing)];
}

#pragma mark - ALVSearchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Clear previous dataset states
    self.imgurImages = nil;
    self.browserPhotos = nil;
    self.pageNum = nil;
    self.isFetchingPage = NO;
    
    // Update collections' states
    BOOL textExists = [searchText length] > 0;
    [self.searchesCollection setHidden:textExists];
    [self.imageCollection setHidden:!textExists];
    
    // Remove all cells
    [self.imageCollection.collectionViewLayout invalidateLayout];
    [self.imageCollection reloadData];
    
    // Start loading animation
    if ([searchText length] > 0) {
        [self.imageCollection animateSpinner:YES];
        
    } else {
        [self.searchesCollection.collectionViewLayout invalidateLayout];
        [self.searchesCollection reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    dispatch_async(dispatch_get_main_queue(), ^{
        [searchBar resignFirstResponder];
        
        // Check if we didnt find any results
        if ([self.customSearchBar.text length] > 0 && !self.pageNum && [self.imgurImages count] == 0) {
            
            // Clear page number
            self.pageNum = nil;
            
            // Show alert
            [self showNoResultsAlert];
        }
    });
}

- (void)searchBar:(ALVSearchBar *)searchBar timedTriggeredTextChange:(NSString *)searchText {
    self.imgurImages = [NSMutableArray new];
    self.browserPhotos = [NSMutableArray new];
    self.pageNum = @0;
    
    // Start Infinite Loading of search results
    [self loadImgurImagesForSearch:searchText pageNumber:self.pageNum];
}

- (void)loadImgurImagesForSearch:(NSString *)searchText pageNumber:(NSNumber *)pageNum {
    if ([searchText isEqualToString:self.customSearchBar.text]) {
        // Set page fetching flag
        self.isFetchingPage = YES;
        
        // Start the image loading for the search term
        [ALVImageManager imagesForSearch:searchText pageNumber:pageNum completion:^(NSArray *foundImages) {
            
            // Reset fetching flag
            self.isFetchingPage = NO;
            
            // Ensure we are still dealing with the same state
            if ([self.customSearchBar.text isEqualToString:searchText]) {
                
                // End loading animation
                [self.imageCollection animateSpinner:NO];
                
                // Check if we didnt find any results
                if ([searchText length] > 0 && [pageNum isEqual:@0] && [foundImages count] == 0) {
                     
                    // Only show alert when the keyboard is retracted
                    if (![self.customSearchBar isFirstResponder]) {
                        // Clear page number
                        self.pageNum = nil;
                        
                        // Show alert
                        [self showNoResultsAlert];
                        return;
                    }
                }
                
                // Save the recent search
                if ([foundImages count] > 0) {
                    [self saveRecentSearch:searchText];
                }
                
                // Update current page number
                self.pageNum = @([self.pageNum integerValue] + 1);
                
                // Load in the found results
                [self.imgurImages addObjectsFromArray:foundImages];
                
                // Create corresponding photos for the browser
                NSMutableArray *browserPhotos = [NSMutableArray new];
                for (ALVImgurImage *imgurImage in foundImages) {
                    NSURL *photoUrl = [NSURL URLWithString:imgurImage.link];
                    [browserPhotos addObject:[MWPhoto photoWithURL:photoUrl]];
                }
                [self.browserPhotos addObjectsFromArray:browserPhotos];
                
                // Insert the new index paths for the fetched images
                NSMutableArray *insertedIndexPaths = [NSMutableArray new];
                for (ALVImgurImage *image in foundImages) {
                    NSIndexPath *indexPath = [self indexPathForImgurImage:image];
                    if (indexPath) {
                        [insertedIndexPaths addObject:indexPath];
                    }
                }
                
                // Append to the image collection
                if ([insertedIndexPaths count] > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageCollection insertItemsAtIndexPaths:insertedIndexPaths];
                    });
                }
                
                // Check if we are done fetching the image results
                if ([foundImages count] == 0) {
                    self.pageNum = nil;
                }
                
                // Trigger scrolling logic manually
                [self scrollViewDidScroll:self.imageCollection];
            }
        }];
    }
}

- (void)saveRecentSearch:(NSString *)searchText {
    if (searchText.length > 0) {
        if ([self.recentSearches containsObject:searchText]) {
            // Need to bump position of search result to top of our list
            [self.recentSearches removeObject:searchText];
            [self.recentSearches insertObject:searchText atIndex:0];
            
        } else {
            // Add and adjust our list
            [self.recentSearches insertObject:searchText atIndex:0];
            
            // Keep recent searches at a cap
            if ([self.recentSearches count] > kMaxNumberSavedPreviousSearches) {
                self.recentSearches = [NSMutableArray arrayWithArray:[self.recentSearches subarrayWithRange:NSMakeRange(0, kMaxNumberSavedPreviousSearches)]];
            }
        }
        
        // Update the User Defaults
        NSString *classRecentSearchesKey = [NSString stringWithFormat:@"%@.recentSearches", [self className]];
        [[NSUserDefaults standardUserDefaults] setObject:self.recentSearches forKey:classRecentSearchesKey];
    }
}

- (void)showNoResultsAlert {
    // Show alert
    NSString *title = @"No Results Found";
    NSString *message = [NSString stringWithFormat:@"Could not find any images matching:\n\'%@\'.\n\nPlease modify your search.", self.customSearchBar.text];
    
    UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [noResultsAlert show];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Check that we aren't already fetching a page
    if (!self.isFetchingPage) {
        
        // Check if we need to start fetching the next page
        if (self.pageNum) {
            CGFloat offsetY = scrollView.contentOffset.y;
            CGFloat contentHeight = scrollView.contentSize.height;
            
            // Check to see if we hit the bottom of our collection
            if (offsetY > contentHeight - kContentHeightMultiplier*scrollView.frame.size.height) {
                
                // Start fetching the next batch of images
                [self loadImgurImagesForSearch:self.customSearchBar.text pageNumber:@([self.pageNum integerValue] + 1)];
            }
        }
    }
}

#pragma mark - ALVCollectionViewDelegate Callbacks
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.searchesCollection]) {
        return [self.recentSearches count];
        
    } else if ([collectionView isEqual:self.imageCollection]) {
        return [self.imgurImages count];
    }
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([collectionView isEqual:self.searchesCollection]) {
        if ([self.recentSearches count] > 0) {
            return self.recentSearchLabel.frame.size;
        }
    }
    
    return CGSizeMake(self.recentSearchLabel.frame.size.width, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.searchesCollection]) {
        return CGSizeMake(self.recentSearchLabel.frame.size.width, kRecentSearchCellDefaultHeight);
    }
    
    return [ALVImgurImageCell cellSize];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reuseCell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[UICollectionReusableView className] forIndexPath:indexPath];
    
    [self.recentSearchLabel removeFromSuperview];
    
    if ([collectionView isEqual:self.searchesCollection]) {
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            if ([self.customSearchBar.text length] == 0) {
                [reuseCell addSubview:self.recentSearchLabel];
            }
        }
    }
    
    return reuseCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UICollectionViewCell className] forIndexPath:indexPath];
    
    if ([collectionView isEqual:self.searchesCollection]) {
        ALVRecentSearchCell *recentSearchCell = [collectionView dequeueReusableCellWithReuseIdentifier:[ALVRecentSearchCell className] forIndexPath:indexPath];
        
        // Set search term text on label here
        [recentSearchCell.recentSearchLabel setText:[self.recentSearches objectAtIndex:indexPath.row]];
        
        cell = recentSearchCell;
        
    } else if ([collectionView isEqual:self.imageCollection]) {
        __block ALVImgurImage *imageData = [self imgurImageForIndexPath:indexPath];
        
        if (imageData) {
            __block ALVImgurImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[ALVImgurImageCell className] forIndexPath:indexPath];
            
            // Check if we need to fetch the thumbnail image for the cell
            if (!imageData.thumbnailImage) {
                [imageCell animteLoading:YES];
                [ALVImageManager fetchImageWithLink:imageData.thumbnailLink completion:^(UIImage *thumbnailImage) {
                    
                    // Update cell UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Save the thumbnail on the imgurImage instance
                        [imageData setThumbnailImage:thumbnailImage];
                        
                        // Update the cell state
                        [imageCell animteLoading:NO];
                        imageCell.imageView.image = thumbnailImage;
                        
                        // Animate image onto cell
                        [imageCell fadeImageIn];
                    });
                }];
            }
            
            cell = imageCell;
            
        } else {
            // Loading Cell
            if (self.isFetchingPage) {
                [self.loadingSpinner startAnimating];
                [cell.contentView addSubview:self.loadingSpinner];
            }
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.imageCollection]) {
        if ([self.customSearchBar.text length] > 0) {
            ALVImgurImage *imageData = [self.imgurImages objectAtIndex:indexPath.row];
            if (imageData) {
                // Prepare cell initial state
                ALVImgurImageCell *imageCell = (id)cell;
                
                [imageCell.imageView setImage:imageData.thumbnailImage];
                [imageCell animteLoading:!imageData.thumbnailImage];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Resign the keyboard whenever the user taps inside a collection
    if ([self.customSearchBar isFirstResponder]) {
        [self.customSearchBar resignFirstResponder];
        
        // Allow the user to view the full image results
        if ([collectionView isEqual:self.imageCollection])
            return;
    }
    
    if ([collectionView isEqual:self.imageCollection]) {
        ALVImgurImage *imgurImage = [self imgurImageForIndexPath:indexPath];
        if (imgurImage) {
            // Push the browser gallery onto the stack
            MWPhotoBrowser *browser = [MWPhotoBrowser photoBrowserWithDelegate:self];
            [browser setCurrentPhotoIndex:indexPath.row];
            
            [self.navigationController pushViewController:browser animated:YES];
        }
        
    } else if ([collectionView isEqual:self.searchesCollection]) {
        NSString *text = [self.recentSearches objectAtIndex:indexPath.row];
        
        [self.customSearchBar resignFirstResponder];
        [self.customSearchBar setText:text];
        
        [self searchBar:self.customSearchBar textDidChange:text];
        [self searchBar:self.customSearchBar timedTriggeredTextChange:text];
    }
}

- (ALVImgurImage *)imgurImageForIndexPath:(NSIndexPath *)indexPath {
    // Validate section
    switch (indexPath.section) {
        case 0: {
            // Validate row
            if (indexPath.row < [self.imgurImages count]) {
                id imgurImage = [self.imgurImages objectAtIndex:indexPath.row];
                
                // Validate class
                if ([[imgurImage class] isSubclassOfClass:[ALVImgurImage class]]) {
                    return imgurImage;
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForImgurImage:(ALVImgurImage *)imgurImage {
    if ([self.imgurImages containsObject:imgurImage]) {
        NSUInteger section = 0;
        NSUInteger row = [self.imgurImages indexOfObject:imgurImage];
        
        return [NSIndexPath indexPathForItem:row inSection:section];
    }
    
    return nil;
}

#pragma mark - MWPhotoBrowserDelegate Methods
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.browserPhotos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [self.browserPhotos count]) {
        return [self.browserPhotos objectAtIndex:index];
    }
    
    return nil;
}

@end

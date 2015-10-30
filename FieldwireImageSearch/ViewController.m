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
#import <AFNetworking/AFNetworking.h>
#import "NSObject+ALVAdditions.h"
#import "MWPhotoBrowser+ALVAdditions.h"

#import <ImgurSession/ImgurSession.h>
#import "ALVSearchBar.h"
#import "ALVCollectionView.h"
#import "ALVImageManager.h"
#import "ALVImgurImageCell.h"
#import "ALVImgurImage.h"

static const CGFloat kCellSpacing = 10;
static const CGFloat kPagingLoadHeight = 40;

@interface ViewController () <ALVSearchBarDelegate, IMGSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate>

@property (strong, nonatomic) ALVSearchBar *customSearchBar;
@property (strong, nonatomic) ALVCollectionView *imageCollection;

@property (strong, nonatomic) NSMutableArray *imgurImages;
@property (strong, nonatomic) NSMutableArray *browserPhotos;
//@property (strong, nonatomic) NSNumber *currentPage;

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
        
        _imageCollection = collectionView;
    }
    return _imageCollection;
}

- (ALVSearchBar *)customSearchBar {
    if (!_customSearchBar) {
        ALVSearchBar *searchBar = [[ALVSearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        searchBar.delegate = self;
        
        _customSearchBar = searchBar;
    }
    return _customSearchBar;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.customSearchBar];
    [self.view addSubview:self.imageCollection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailImageFetchedNotification:) name:kFetchedThumbnailImageNotification object:nil];
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
    [self.customSearchBar setFrame:CGRectMake(0, yOffset, SCREEN_WIDTH, 44)];
    
    yOffset += self.customSearchBar.frame.size.height;
    [self.imageCollection setFrame:CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset)];
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

#pragma mark - ALVSearchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Clear previous dataset states
        self.imgurImages = nil;
        self.browserPhotos = nil;
        //self.currentPage = nil;
        
        // Remove all cells
        [self.imageCollection reloadData];
        
        // Start loading animation
        if ([searchText length] > 0) {
            [self.imageCollection animateSpinner:YES];
        }
    });
}

- (void)searchBar:(ALVSearchBar *)searchBar timedTriggeredTextChange:(NSString *)searchText {
    self.imgurImages = [NSMutableArray new];
    self.browserPhotos = [NSMutableArray new];
    //self.currentPage = @0;
    
    // Start Infinite Loading of search results
    [self loadImgurImagesForSearch:searchText pageNumber:@0];
    
    
    /*// Start the image loading for the search term
    __block NSString *searchTerm = searchText;
    
    [ALVImageManager imagesForSearch:searchText pageNumber:self.currentPage completion:^(NSArray *foundImages) {
        if ([self.customSearchBar.text isEqualToString:searchTerm]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Load in the found results
                self.imgurImages = [NSMutableArray arrayWithArray:foundImages];
                
                // Create corresponding photos for the browser
                NSMutableArray *browserPhotos = [NSMutableArray new];
                for (ALVImgurImage *imgurImage in foundImages) {
                    NSURL *photoUrl = [NSURL URLWithString:imgurImage.link];
                    [browserPhotos addObject:[MWPhoto photoWithURL:photoUrl]];
                }
                self.browserPhotos = browserPhotos;
        
                // Reload the dataset
                [self.imageCollection reloadData];
                
                // End loading animation
                [self.imageCollection animateSpinner:NO];
            });
        }
    }];*/
}

- (void)loadImgurImagesForSearch:(NSString *)searchText pageNumber:(NSNumber *)pageNum {
    if ([searchText isEqualToString:self.customSearchBar.text]) {
        
        // Start the image loading for the search term
        [ALVImageManager imagesForSearch:searchText pageNumber:pageNum completion:^(NSArray *foundImages) {
            
            // Ensure we are still dealing with the same state
            if ([self.customSearchBar.text isEqualToString:searchText]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // End loading animation
                    [self.imageCollection animateSpinner:NO];
                    
                    // Check if we didnt find any results
                    if ([searchText length] > 0 && [pageNum isEqual:@0] && [foundImages count] == 0) {
                        NSString *title = @"No Results Found";
                        NSString *message = [NSString stringWithFormat:@"Could not find any images matching:\n\'%@\'.\n\nPlease modify your search.", searchText];
                        
                        UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [noResultsAlert show];
                        
                        return;
                    }
                    
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
                    [self.imageCollection insertItemsAtIndexPaths:insertedIndexPaths];
                    
                    // Check if we need to start fetching the next page
                    if ([foundImages count] > 0) {
                        [self loadImgurImagesForSearch:searchText pageNumber:@([pageNum integerValue] + 1)];
                    }
                });
            }
        }];
    }
}

#pragma mark - ALVCollectionViewDelegate Callbacks
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imgurImages count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kImageCellDefaultWidth, kImageCellDefaultHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[UICollectionViewCell className] forIndexPath:indexPath];
    
    __block ALVImgurImage *imageData = [self.imgurImages objectAtIndex:indexPath.row];
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
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ALVImgurImage *imageData = [self.imgurImages objectAtIndex:indexPath.row];
    if (imageData) {
        // Prepare cell initial state
        ALVImgurImageCell *imageCell = (id)cell;
        
        [imageCell.imageView setImage:imageData.thumbnailImage];
        [imageCell animteLoading:!imageData.thumbnailImage];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALVImgurImage *imgurImage = [self imgurImageForIndexPath:indexPath];
    if (imgurImage) {
        // Push the browser gallery onto the stack
        MWPhotoBrowser *browser = [MWPhotoBrowser photoBrowserWithDelegate:self];
        [browser setCurrentPhotoIndex:indexPath.row];
        
        [self.navigationController pushViewController:browser animated:YES];
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

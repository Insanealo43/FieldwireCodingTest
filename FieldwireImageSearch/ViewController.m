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

#import <ImgurSession/ImgurSession.h>
#import "ALVSearchBar.h"
#import "ALVCollectionView.h"
#import "ALVImageManager.h"
#import "ALVImgurImageCell.h"
#import "ALVImgurImage.h"

static const CGFloat kCellSpacing = 10;

@interface ViewController () <ALVSearchBarDelegate, IMGSessionDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) ALVSearchBar *customSearchBar;
@property (strong, nonatomic) ALVCollectionView *imageCollection;

@property (strong, nonatomic) NSMutableArray *imgurImages;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}
-(void)viewWillLayoutSubviews {
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
            
            NSUInteger imageIndex = [self.imgurImages indexOfObject:notification.object];
            NSIndexPath *imageIndexPath = [NSIndexPath indexPathForRow:imageIndex inSection:0];
            
            // Validate index path of image cell
            if ([self.imageCollection numberOfSections] > 0) {
                if ([self.imageCollection numberOfItemsInSection:0] > imageIndexPath.row) {
                    
                    // Reconfigure the cell
                    ALVImgurImageCell *imageCell = (id)[self.imageCollection cellForItemAtIndexPath:imageIndexPath];
                    [imageCell setImageData:imgurImage];
                }
            }
        }
    }
}

#pragma mark - ALVSearchBarDelegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Clear previous dataset
        self.imgurImages = nil;
        [self.imageCollection reloadData];
        
        // Start loading animation
        [self.imageCollection animateSpinner:YES];
    });
}

- (void)searchBar:(ALVSearchBar *)searchBar timedTriggeredTextChange:(NSString *)searchText {
    // Start the image loading for the search term
    __block NSString *searchTerm = searchText;
    
    [ALVImageManager imagesForSearch:searchText completion:^(NSArray *foundImages) {
        if ([self.customSearchBar.text isEqualToString:searchTerm]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Load in the found results
                self.imgurImages = [NSMutableArray arrayWithArray:foundImages];
                [self.imageCollection reloadData];
                
                
                // End loading animation
                [self.imageCollection animateSpinner:NO];
            });
        }
    }];
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
    
    switch (indexPath.section) {
        case 0: {
            __block ALVImgurImage *imageData = [self.imgurImages objectAtIndex:indexPath.row];
            __block ALVImgurImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:[ALVImgurImageCell className] forIndexPath:indexPath];
            
            // Check if we need to fetch the thumbnail image for the cell
            if (!imageData.thumbnailImage) {
                [imageCell animteLoading:YES];
                [ALVImageManager fetchImageWithLink:imageData.thumbnailLink completion:^(UIImage *thumbnailImage) {
                    
                    // Update cell UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageData setThumbnailImage:thumbnailImage];
                        [imageCell animteLoading:NO];
                        imageCell.imageView.image = thumbnailImage;
                    });
                }];
            }
                        
            cell = imageCell;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0: {
            // Prepare cell initial state
            ALVImgurImage *imageData = [self.imgurImages objectAtIndex:indexPath.row];
            ALVImgurImageCell *imageCell = (id)cell;
            
            [imageCell.imageView setImage:imageData.thumbnailImage];
            [imageCell animteLoading:!imageData.thumbnailImage];
        }
            
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

//
//  MWPhotoBrowser+ALVAdditions.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/30/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "MWPhotoBrowser+ALVAdditions.h"

@implementation MWPhotoBrowser (ALVAdditions)

+ (MWPhotoBrowser *)photoBrowserWithDelegate:(id<MWPhotoBrowserDelegate>)delegate {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:delegate];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    return browser;
}

@end

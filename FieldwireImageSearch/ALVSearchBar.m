//
//  ALVSearchBar.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVSearchBar.h"
#import "ALVDelegateInterceptor.h"
#import "ALVGlobals.h"

static const CGFloat kTimerDefaultDuration = 0.2;
static const CGFloat kSearchBarDefaultHeight = 40;
static NSString *const kSearchTextKey = @"search_text_key";

@interface ALVSearchBar () <UISearchBarDelegate>

@property (strong, nonatomic) ALVDelegateInterceptor *searchBarInterceptor;
@property (strong, nonatomic) NSTimer *searchTextChangedTimer;

@end


@implementation ALVSearchBar
@synthesize placeholder = _placeholder;
@synthesize text = _text;

- (void)dealloc {
    // Remove listeners
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.searchTextChangedTimer invalidate];
    self.searchTextChangedTimer = nil;
    self.searchBarInterceptor = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSearchBar];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSearchBar];
    }
    return self;
}

+ (instancetype)searchBarWithDelegate:(id<ALVSearchBarDelegate>)delegate {
    ALVSearchBar *searchBar = [[self alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchBarDefaultHeight)];
    [searchBar initSearchBar];
    [searchBar setDelegate:delegate];
    return searchBar;
}

- (instancetype)initWithDelegate:(id<ALVSearchBarDelegate>)delegate {
    self = [super init];
    if (self) {
        [self initSearchBar];
        self.delegate = delegate;
    }
    
    return self;
}

- (void)initSearchBar {
    [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchBarDefaultHeight)];
    
    self.searchBarInterceptor = [[ALVDelegateInterceptor alloc] initWithArrayOfInterceptedProtocols:@[@protocol(UISearchBarDelegate)]];
    [self.searchBarInterceptor setInterceptor:self];
    [super setDelegate:(id)_searchBarInterceptor];
    
    // Add Textfield listeners
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    // Normalize the search bar properties
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self setSearchBarStyle:UISearchBarStyleMinimal];
    
    [self setTintColor:[UIColor blueColor]];
    [self setBarTintColor:[UIColor whiteColor]];
    [[self textField] setPlaceholder:@"Search Imgur"];
}

- (void)configure {
    [self initSearchBar];
}

- (UITextField *)textField {
    for (UIView* subview in [[self.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:[UITextField class]]) {
            return (UITextField*)subview;
        }
    }
    return nil;
}

- (id<ALVSearchBarDelegate>)delegate {
    return self.searchBarInterceptor.originalTarget;
}

- (void)setDelegate:(id<ALVSearchBarDelegate>)delegate {
    [super setDelegate:nil];
    [self.searchBarInterceptor setOriginalTarget:delegate];
    [super setDelegate:(id)_searchBarInterceptor];
}

#pragma mark - Getter Methods
- (NSTimeInterval)triggerDuration {
    return _triggerDuration > 0.0 ? _triggerDuration : kTimerDefaultDuration;
}

- (BOOL)isSearching {
    return [[[self textField] text] length] > 0;
}

- (NSString *)text {
    return [[self textField] text];
}

#pragma mark - Setter Methods
- (void)setText:(NSString *)text {
    _text = text;
    
    UITextField *textField = [self textField];
    [textField setText:text];
    
    /*NSMutableAttributedString *textAttr = [NSMutableAttributedString string:text font:textField.font color:textField.textColor textAlignment:textField.textAlignment];
    [textField setAttributedText:textAttr];*/
}

/*- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    
    UITextField *textField = [self textField];
    NSMutableAttributedString *placeholderAttr = [NSMutableAttributedString string:placeholder font:textField.font color:textField.textColor textAlignment:textField.textAlignment];
    [textField setAttributedPlaceholder:placeholderAttr];
}*/

#pragma mark - Callback Methods
- (void)textDidChange:(NSNotification *)notification {
    if ([[notification.object class] isSubclassOfClass:[UITextField class]]) {
        if ([notification.object isEqual:[self textField]]) {
            if ([[notification object] respondsToSelector:@selector(text)]) {
                NSString *text = [[[notification object] text] length] > 0 ? [[notification object] text] : @"";
                
                // Invalidate timer
                [self.searchTextChangedTimer invalidate];
                self.searchTextChangedTimer = nil;
                
                self.searchTextChangedTimer = [NSTimer scheduledTimerWithTimeInterval:[self triggerDuration] target:self selector:@selector(searchTimerFired:) userInfo:@{kSearchTextKey : text} repeats:NO];
            }
        }
    }
}

- (void)searchTimerFired:(NSTimer *)searchTimer {
    NSString *newSearchText = [searchTimer.userInfo objectForKey:kSearchTextKey];
    if (newSearchText) {
        // Ensure that that the timed triggered text is sync'd with the searchbar's current text
        if ([newSearchText isEqualToString:self.text]) {
            if ([[self delegate] respondsToSelector:@selector(searchBar:timedTriggeredTextChange:)]) {
                [[self delegate] searchBar:self timedTriggeredTextChange:newSearchText];
            }
        }
        
        // Invalidate the search timer
        if ([searchTimer isEqual:self.searchTextChangedTimer]) {
            [self.searchTextChangedTimer invalidate];
            self.searchTextChangedTimer = nil;
        }
    }
}

#pragma mark - ALVSearchBarIntercepted Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([[self delegate] respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [[self delegate] searchBarSearchButtonClicked:self];
    }
    
    NSString *currentSearchTimerText = [self.searchTextChangedTimer.userInfo objectForKey:kSearchTextKey];
    if (currentSearchTimerText && ![searchBar.text isEqualToString:currentSearchTimerText]) {
        // Invalidate the search timer
        [self.searchTextChangedTimer invalidate];
        self.searchTextChangedTimer = nil;
        
        if ([[self delegate] respondsToSelector:@selector(searchBar:timedTriggeredTextChange:)]) {
            [[self delegate] searchBar:self timedTriggeredTextChange:currentSearchTimerText];
        }
    }
    
    [self resignFirstResponder];
}

@end

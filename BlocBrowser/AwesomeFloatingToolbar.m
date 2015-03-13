//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Ira Auerbach on 3/12/15.
//  Copyright (c) 2015 Ira Auerbach. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"
#import "WebBrowserViewController.h"

@interface AwesomeFloatingToolbar()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
//@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation AwesomeFloatingToolbar

#pragma mark - Initialization and Layout

-(instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        //save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1], [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],[UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],[UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        UIButton *backButton = [[UIButton alloc] init];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        backButton.backgroundColor = [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backButton.showsTouchWhenHighlighted = YES;
        [backButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsArray addObject:backButton];
        
        UIButton *forwardButton = [[UIButton alloc] init];
        [forwardButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [forwardButton setTitle:@"Forward" forState:UIControlStateNormal];
        forwardButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1];
        [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        forwardButton.showsTouchWhenHighlighted = YES;
        [forwardButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsArray addObject:forwardButton];
        
        UIButton *stopButton = [[UIButton alloc] init];
        [stopButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        stopButton.backgroundColor = [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1];
        [stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        stopButton.showsTouchWhenHighlighted = YES;
        [stopButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsArray addObject:stopButton];
        
        UIButton *refreshButton = [[UIButton alloc] init];
        [refreshButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
        refreshButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1];
        [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        refreshButton.showsTouchWhenHighlighted = YES;
        [refreshButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsArray addObject:refreshButton];
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        //[self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
    }
    
    return self;
}

-(void) layoutSubviews {
    //set the frames for the four buttons
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        //adjust labelX and labelY for each label
        if (currentButtonIndex<2){
            //0 or 1, so on top
            buttonY=0;
        } else {
            //2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 ==0) {
            //0 or 2, so on the left
            buttonX = 0;
        } else {
            //1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Touch Handling

-(UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}

#pragma mark - Button Enabling

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];

    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

#pragma mark - Tap Gesture Methods

/*-(void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}*/

-(void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"new translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    
    //rotate the colors counterclockwise
    UILabel *buttonAtIndexZero = [self.buttons objectAtIndex:0];
    UIColor *indexZeroBackgroundColor = buttonAtIndexZero.backgroundColor;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        for (UIButton *thisButton in self.buttons) {
            NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
            NSUInteger newColorIndex = (currentButtonIndex + 1) % 4;
            if(newColorIndex==0) {
                thisButton.backgroundColor = indexZeroBackgroundColor;
            } else {
                UIButton *buttonOneAhead = [self.buttons objectAtIndex:newColorIndex];
                thisButton.backgroundColor = buttonOneAhead.backgroundColor;
            }
        }
        
    }
    
}

-(void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didPinchWithScale:scale];
        }
    }
}

-(IBAction)buttonPressed:(id)sender {
    NSString *title = [(UIButton *)sender currentTitle];
    
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didButtonPressed:)]) {
        [self.delegate floatingToolbar:self didButtonPressed:title];
    }
    
}

@end


























//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Ira Auerbach on 3/12/15.
//  Copyright (c) 2015 Ira Auerbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchWithScale:(CGFloat)scale;

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didButtonPressed:(NSString *)title;

@end

@interface AwesomeFloatingToolbar : UIView

-(instancetype) initWithFourTitles:(NSArray *)titles;

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@end

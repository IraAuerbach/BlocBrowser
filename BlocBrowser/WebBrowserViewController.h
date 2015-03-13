//
//  WebBrowserViewController.h
//  BlocBrowser
//
//  Created by Ira Auerbach on 3/9/15.
//  Copyright (c) 2015 Ira Auerbach. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back Command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward Command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop Command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh Command")

@interface WebBrowserViewController : UIViewController

-(void) resetWebView;

@end

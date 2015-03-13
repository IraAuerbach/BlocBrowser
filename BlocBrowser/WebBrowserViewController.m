//
//  WebBrowserViewController.m
//  BlocBrowser
//
//  Created by Ira Auerbach on 3/9/15.
//  Copyright (c) 2015 Ira Auerbach. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back Command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward Command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop Command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Refresh Command")

@interface WebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation WebBrowserViewController

#pragma mark - UIViewController

-(void) loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    for(UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    //[self.activityIndicator startAnimating];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //first calculate some dimensions
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    //now assign the frames
    self.textField.frame = CGRectMake(0,0,width,itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake((width - 280) / 2, 100, 280, 60);
}

#pragma mark - UITextFieldDelegate

//where we decide what webpage to load
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if ([URLString containsString:@" "]) {
        [self googleSearch];
    }
    if (!URL.scheme) {
        //the user didn't type http: or https:
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",URLString]];
    }
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

-(void) webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(error.code != -999) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!!!", @"Error!!!") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateButtonsAndTitle];
    self.frameCount --;
}

#pragma mark - Miscellaneous

-(void) updateButtonsAndTitle {
    NSString *webpageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.request.URL.absoluteString;
    }
    
    if (self.frameCount>0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webView.request.URL && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];
}

-(void) googleSearch {
    NSString *searchStringWithSpaces = self.textField.text;
    NSString *searchStringWithPluses = [searchStringWithSpaces stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *googleSearchString =  [NSString stringWithFormat:@"https://www.google.com/search?q=%@", searchStringWithPluses];
    NSURL *googleURL = [NSURL URLWithString:googleSearchString];
    NSURLRequest *googleRequest = [NSURLRequest requestWithURL:googleURL];
    [self.webView loadRequest:googleRequest];
}

-(void) resetWebView {
    [self.webView removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

#pragma mark - AwesomeFloatingToolbarDelegate

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:kWebBrowserBackString]) { //NSLocalizedString(@"Back", @"Back Command")]) {
        [self.webView goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

@end




















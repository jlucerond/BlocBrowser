//
//  ViewController.m
//  BlocBrowser
//
//  Created by Joe Lucero on 5/5/15.
//  Copyright (c) 2015 Joe Lucero. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "JLAwesomeFloatingToolbar.h"

#define kJLWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kJLWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kJLWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kJLWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, JLAwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) JLAwesomeFloatingToolbar *awesomeToolbar;

// note for Mark- I know this new curriculum is beta, but it looks like this was taken out of the previous curriculum and was never added back in (shows up for the first time in "adding the toolbar to the view controller") there's a few things in this section that need to be double checked actually, since the hw was to refactor some of the code, it looks slightly different than what was here
@property (nonatomic, assign) NSUInteger frameCount;

@end

#pragma mark - UIViewController

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];    
}

- (void) loadView{
    UIView *mainView = [UIView new];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc]init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"     Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    // add buttons for web browser
    self.awesomeToolbar = [[JLAwesomeFloatingToolbar alloc] initWithFourTitles:@[kJLWebBrowserBackString, kJLWebBrowserForwardString, kJLWebBrowserStopString, kJLWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    // first, calculating dimensions:
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    NSInteger myCGFloatX = (CGRectGetWidth(self.view.bounds) - 280)/2;
    NSInteger myCGFloatY = CGRectGetHeight(self.view.bounds) - 60;
    
    // now assign frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    self.awesomeToolbar.frame = CGRectMake(myCGFloatX, myCGFloatY, 280, 60);
    
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    NSRange rangeSearchingForSpace = [URLString rangeOfString:@" "];
    NSRange rangeSearchingForDot = [URLString rangeOfString:@"."];

    // if URLString has no spaces & does have a dot in it do this:
    if (rangeSearchingForSpace.location > 100000 && rangeSearchingForDot.location < 100000){
        NSURL *URL = [NSURL URLWithString:URLString];
    
        if (!URL.scheme){
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
        }
    
        if (URL){
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [self.webView loadRequest:request];
        }
    
        textField.text = @"";
    }
    
    // else, create a google search for the item:    
    else {
        NSString *StringForGoogleSearch = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", [URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        
        NSURL *GoogleSearchURL = [NSURL URLWithString:StringForGoogleSearch];
        NSURLRequest *request = [NSURLRequest requestWithURL:GoogleSearchURL];
        [self.webView loadRequest:request];
        textField.text = @"";
        
    }
    
    return NO;
}

#pragma mark - WKNavigationDelegate

- (void) webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error {
        [self webView:webView didFailNavigation:navigation withError:error];
    [self updateButtonsAndTitle];
    }

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (error.code != NSURLErrorCancelled){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SOMETHING'S WRONG", @"There's been an error") message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"DARN", @"everything is ok") style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self updateButtonsAndTitle];
}

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

#pragma mark - Misc.

- (void) updateButtonsAndTitle {
    NSString *webPageTitle = [self.webView.title copy];
    if ([webPageTitle length]){
        self.title = webPageTitle;
    }
    
    else {
        self.title = self.webView.URL.absoluteString;
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kJLWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kJLWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kJLWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kJLWebBrowserRefreshString];
    
    if (self.webView.isLoading){
            [self.activityIndicator startAnimating];
    }
    else {
            [self.activityIndicator stopAnimating];
    }
}

- (void) resetWebView{
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc]init];
    newWebView.navigationDelegate = self;
    self.webView = newWebView;
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    [self.view addSubview:newWebView];
    [self.view sendSubviewToBack:newWebView];

    NSLog(@"reset");
}

- (void) sayHi {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BlocBrowser", @"Name of App") message: @"Welcome back to BlocBrowser!" preferredStyle:UIAlertControllerStyleAlert];
//    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ready to Browse", @"everything is ok") style:UIAlertActionStyleCancel handler:nil];
//    
//    [alert addAction:okAction];
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void) floatingToolbar:(JLAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title{
    if ([title isEqual:kJLWebBrowserBackString]){
        [self.webView goBack];
    }
    
    else if ([title isEqual:kJLWebBrowserForwardString]){
        [self.webView goForward];
    }
    
    else if ([title isEqual:kJLWebBrowserStopString]){
        [self.webView stopLoading];
    }
    
    else if ([title isEqual:kJLWebBrowserRefreshString]){
        [self.webView reload];
    }
}

- (void) floatingToolbar:(JLAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)){
        toolbar.frame = potentialNewFrame;
    }
}

// GOT STUCK FOR THREE HOURS CAN'T FIGURE OUT WHAT TO DO NOW
- (void)floatingToolbar:(JLAwesomeFloatingToolbar *)toolbar didTryToPinch:(CGFloat)scale {
    
    // this is one of the things that I googled and didn't really understand
//    toolbar.transform = CGAffineTransformScale(toolbar.transform, 100, 100);
//    self.awesomeToolbar.frame = toolbar.frame;
    
    // this was my best attempt at trying to do this by myself
    // for some reason, the frame resets to the bottom of the screen every time I run this. I can't find any other CGRect that works better than .frame
    CGRect currentFrame = toolbar.frame;
    
    CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, (currentFrame.size.width + scale), (currentFrame.size.height + scale));
    
    self.awesomeToolbar.frame = newFrame;
}

@end

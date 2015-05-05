//
//  ViewController.m
//  BlocBrowser
//
//  Created by Joe Lucero on 5/5/15.
//  Copyright (c) 2015 Joe Lucero. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

#pragma mark - UIViewController

@implementation ViewController

- (void)viewDidLoad {
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
    
// hard coded for going to wiki; adapt now to user's text field
//    NSString *urlString = @"http://wikipedia.org";
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
    
    // add buttons for web browser
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back command") forState:UIControlStateNormal];
    [self.backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward command") forState:UIControlStateNormal];
    [self.forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop command") forState:UIControlStateNormal];
    [self.stopButton addTarget:self.webView action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton setTitle:NSLocalizedString(@"Reload", @"Reload command") forState: UIControlStateNormal];
    [self.reloadButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    
//    simplified in the below for loop
//    [mainView addSubview:self.textField];
//    [mainView addSubview:self.webView];
//    [mainView addSubview:self.backButton];
//    [mainView addSubview:self.forwardButton];
//    [mainView addSubview:self.reloadButton];
//    [mainView addSubview:self.stopButton];
    
    for (UIView *viewToAdd in @[self.webView, self.textField, self.backButton, self.forwardButton, self.reloadButton, self.stopButton]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void) viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    // first, calculating dimensions:
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds)/4;
    
    // now assign frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButtonX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]){
        thisButton.frame = CGRectMake(currentButtonX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHeight);
        currentButtonX += buttonWidth;
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    NSRange rangeSearchingForSpace = [URLString rangeOfString:@" "];

    // if URLString has no spaces in it do this:
    if (rangeSearchingForSpace.location > 100000){
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

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *) navigation withError:(NSError *)error {
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

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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
    
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.stopButton.enabled = self.webView.isLoading;
    self.reloadButton.enabled = !self.webView.isLoading;
    
    if (self.webView.isLoading){
            [self.activityIndicator startAnimating];
    }
    else {
            [self.activityIndicator stopAnimating];
    }
}

@end

//
//  JLAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Joe Lucero on 5/6/15.
//  Copyright (c) 2015 Joe Lucero. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  JLAwesomeFloatingToolbar;

// note for me
// messages that the class generates and sends to the ViewController (in this case, could be anywhere else)

@protocol JLAwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void) floatingToolbar: (JLAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle: (NSString *)title;

- (void) floatingToolbar: (JLAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset: (CGPoint)offset;

- (void) floatingToolbar: (JLAwesomeFloatingToolbar *)toolbar didTryToPinch: (CGFloat)scale;

@end


//note for me
// things that you do to the class

// interface for toolbar?
@interface JLAwesomeFloatingToolbar : UIView

// must initialize with an array of titles
- (instancetype) initWithFourTitles:(NSArray *)titles;

// the button is enabled or not based on the title?
- (void) setEnabled:(BOOL) enabled forButtonWithTitle:(NSString *)title;

// not sure what delegate means here
@property (nonatomic, weak) id <JLAwesomeFloatingToolbarDelegate> delegate;

@end

//
//  JLAwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Joe Lucero on 5/6/15.
//  Copyright (c) 2015 Joe Lucero. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  JLAwesomeFloatingToolbar;

@protocol JLAwesomeFloatingToolbarDelegate <NSObject>

@optional

// why is this one placed here above the @interface? is this because the methods here are optional while the ones below (after @interface) are required?

- (void) floatingToolbar: (JLAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle: (NSString *)title;

- (void) floatingToolbar:(JLAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset: (CGPoint) offset;
@end

// interface for toolbar?
@interface JLAwesomeFloatingToolbar : UIView

// must initialize with an array of titles
- (instancetype) initWithFourTitles:(NSArray *)titles;

// the button is enabled or not based on the title?
- (void) setEnabled:(BOOL) enabled forButtonWithTitle:(NSString *)title;

// not sure what delegate means here
@property (nonatomic, weak) id <JLAwesomeFloatingToolbarDelegate> delegate;

@end

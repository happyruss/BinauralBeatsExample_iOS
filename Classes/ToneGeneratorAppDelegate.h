//
//  Binaural
//
//  Created by Russell Dobda 2015.
//  Copyright 2015 Russell Dobda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToneGeneratorViewController;

@interface ToneGeneratorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ToneGeneratorViewController *viewController;
    UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ToneGeneratorViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@end


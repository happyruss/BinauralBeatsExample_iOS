//
//  main.m
//  Binaural
//
//  Created by Russell Dobda
//

#import <UIKit/UIKit.h>
#import "ToneGeneratorAppDelegate.h"


int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([ToneGeneratorAppDelegate class]));
    [pool release];
    return retVal;
    
/* use storyboard
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ToneGeneratorAppDelegate class]));
    }
*/
}

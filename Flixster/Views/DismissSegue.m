//
//  DismissSegue.m
//  Flixster
//
//  Created by Martin Winton on 6/28/18.
//  Copyright © 2018 Martin Winton. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform {
    UIViewController *sourceViewController = self.sourceViewController;
    [sourceViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end

//
//  ActivityViewController.m
//  Filterer
//
//  Created by lilil on 24.12.15.
//  Copyright © 2015 UofT. All rights reserved.
//

#import "ActivityViewController.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

- (BOOL)_shouldExcludeActivityType:(UIActivity *)activity
{
    NSLog(@"TYPE: %@", [activity activityType]);
//    if ([[activity activityType] isEqualToString:@"com.vk.vkclient.shareextension"]) {
//        return YES;
//    }
    return [super _shouldExcludeActivityType:activity];
}


@end

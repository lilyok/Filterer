//
//  ActivityViewController.h
//  Filterer
//
//  Created by lilil on 24.12.15.
//  Copyright © 2015 UofT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityViewController (Private)

- (BOOL)_shouldExcludeActivityType:(UIActivity*)activity;

@end

@interface ActivityViewController : UIActivityViewController


@end

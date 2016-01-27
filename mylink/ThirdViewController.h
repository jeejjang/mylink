//
//  ThirdViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 12. 1..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FirstViewController.h"

@class FirstViewController;

@interface ThirdViewController : UITableViewController<UIAlertViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    NSString *myNumOfRelations;
    NSString *version;
    
    //image
    UIImage *more_blind;
    UIImage *more_node;
    UIImage *more_up;
    UIImage *more_up2;
    UIImage *more_version;
    UIImage *more_story;
    UIImage *more_privacy;
    UIImage *more_email;
    UIImage *more_out;
    
}

@property FirstViewController *first;

@end

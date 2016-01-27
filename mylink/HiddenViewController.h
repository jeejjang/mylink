//
//  HiddenViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 10. 31..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@class FirstViewController;

@interface HiddenViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *tableView_hidden;
    IBOutlet UIActivityIndicatorView *indicator;
    
    NSUInteger curIndex;
    NSString *curName;
    NSString *curPhone;
    NSString *curMyLinkID;
    //NSUInteger curLogin;
}

@property FirstViewController *first;
@property long myid;
@property NSMutableArray *name_hidden;
@property NSMutableArray *phone_hidden;
@property NSMutableArray *myLinkID_hidden;

@end

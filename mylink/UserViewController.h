//
//  UserViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 4..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondViewController.h"

@class SecondViewController;

@interface UserViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView_user;
    
    NSArray *sectionTitles;
    NSMutableArray *sectionIndexTitles;
}


@property SecondViewController *second;
@property NSInteger flag;   // 1:btn1 / 2:btn2
@property NSMutableDictionary *name_dic;
@property NSMutableDictionary *phone_dic;
@property NSMutableDictionary *myLinkID_dic;


- (IBAction)cancelClicked:(id)sender;



@end

//
//  UserSelectViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 6..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlindSMSViewController.h"

@interface UserSelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView_user;
    
    IBOutlet UIBarButtonItem *btnSelect;
    
    NSArray *sectionTitles;
    NSMutableArray *sectionIndexTitles;
    
    //선택된 셀의 indexpath 배열
    NSArray *selectedCell_array;
}

@property BlindSMSViewController *blind;
@property NSMutableDictionary *name_dic;
@property NSMutableDictionary *phone_dic;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)btnSelectClicked:(id)sender;

@end

//
//  UserRankViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 12. 29..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRankViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    
    IBOutlet UISegmentedControl *segCtrl;
    
    IBOutlet UITableView *tableView_user;
    
    NSArray *sectionTitles;
    NSMutableArray *sectionIndexTitles;
    
    //초성순
    NSMutableDictionary *rank_dic;
    //지수순
    NSMutableArray *name_array;
    NSMutableArray *rank_array;
}

@property long myid;
@property NSMutableDictionary *name_dic;
@property NSMutableDictionary *myLinkID_dic;

- (IBAction)segCtrlValueChanged:(id)sender;
- (IBAction)cancelClicked:(id)sender;


@end

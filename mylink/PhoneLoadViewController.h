//
//  PhoneLoadViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 6. 19..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlindSMSViewController.h"

@interface PhoneLoadViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UITableView *tableView_phone;
    
    //data
    NSMutableArray *titles_array;
    NSMutableArray *dates_array;
    NSMutableArray *texts_arrayOfArray;
    NSMutableArray *phones_arrayOfArray;
    
    NSIndexPath *curIndexPath; //매개변수
    
    IBOutlet UIBarButtonItem *btnEdit;
}

@property BlindSMSViewController *blind;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)btnEditClicked:(id)sender;

@end

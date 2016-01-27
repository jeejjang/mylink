//
//  NodeBuyViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 8..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "FirstViewController.h"
#import "ThirdViewController.h"

@interface NodeBuyViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    IBOutlet UITableView *tableView_node;
    IBOutlet UILabel *label_curNode;
    
}

@property FirstViewController *first;
@property ThirdViewController *third;

- (IBAction)btnCloseClicked:(id)sender;

@end

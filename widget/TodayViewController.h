//
//  TodayViewController.h
//  widget
//
//  Created by JeongMin Ji on 2015. 9. 1..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController
{
    long myid;
    //NSString *today_phone;
    //NSMutableArray *today_phone_array;
    //BOOL isReloadSearch;
}
@property (strong, nonatomic) IBOutlet UILabel *today_label1;
@property (strong, nonatomic) IBOutlet UILabel *today_label2;
@property (strong, nonatomic) IBOutlet UIButton *today_appBtn;


@end

//
//  HistoryCell.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 8. 26..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HipsterLabel.h"

@interface HistoryCell : UITableViewCell

//@property (strong, nonatomic) UILabel *label_send;
//@property (strong, nonatomic) UILabel *label_name;
//@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *label_receiver;
@property (strong, nonatomic) IBOutlet UILabel *label_date;
@property (strong, nonatomic) IBOutlet HipsterLabel *label_text;
@property (strong, nonatomic) IBOutlet UIButton *btn_del;


@end

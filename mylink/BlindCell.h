//
//  BlindCell.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 6. 18..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlindCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *label_num;
@property (strong, nonatomic) IBOutlet UILabel *label_phone;
@property (strong, nonatomic) IBOutlet UIButton *btn_del;

@end

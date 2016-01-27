//
//  SearchCell1.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 13..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell1 : UITableViewCell

//@property (strong, nonatomic) IBOutlet UIImageView *imageView_back;
@property (strong, nonatomic, readwrite) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *label_names;
@property UILabel *label_names2;
@property NSString *str_label_names2;
@property (strong, nonatomic) IBOutlet UILabel *label_date;

@property (strong, nonatomic) IBOutlet UIView *view_first;


@property (strong, nonatomic) IBOutlet UIButton *btn_update;    //새로 검색
@property (strong, nonatomic) IBOutlet UIButton *btn_minus;

@end

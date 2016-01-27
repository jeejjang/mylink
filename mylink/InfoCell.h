//
//  InfoCell.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *cell_label;
@property UIButton *kakaoLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *btn_blind;

@end

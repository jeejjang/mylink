//
//  InfoCell1.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell1 : UITableViewCell <UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIButton *cell_webBtn;
@property (strong, nonatomic) IBOutlet UIImageView *cell_imageView;
@property (strong, nonatomic) IBOutlet UILabel *cell_label;
@property (strong, nonatomic) IBOutlet UIScrollView *cell_bg_scrollView;
@property UIImageView *cell_bg_imageView;


@end

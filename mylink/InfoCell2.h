//
//  InfoCell2.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell2 : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *cell_date_label;
@property (strong, nonatomic) IBOutlet UILabel *cell_content_label;
@property (strong, nonatomic) IBOutlet UIScrollView *cell_scrollView;

@end

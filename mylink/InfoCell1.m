//
//  InfoCell1.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "InfoCell1.h"

@implementation InfoCell1
@synthesize cell_bg_scrollView, cell_bg_imageView;

- (void)awakeFromNib {
    // Initialization code
    cell_bg_scrollView.delegate = self;
    //cell_bg_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cell_bg_scrollView.frame.size.width, 170.0f)];
    //[cell_bg_scrollView addSubview:cell_bg_imageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return cell_bg_imageView;
}

@end

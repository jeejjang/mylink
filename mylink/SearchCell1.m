//
//  SearchCell1.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 13..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "SearchCell1.h"

@implementation SearchCell1
@synthesize imageView, view_first, label_names2, str_label_names2;
- (void)awakeFromNib {
    // Initialization code
    //[self.contentView bringSubviewToFront:view_first];
    label_names2 = nil;
    str_label_names2 = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

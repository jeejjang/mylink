//
//  HistoryCell.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 8. 26..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell
@synthesize label_text;
- (void)awakeFromNib {
    // Initialization code
    //label_send = nil;
    //label_name = nil;
    //imageView = nil;
    //Menu
    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [label_text addGestureRecognizer:gestureRecognizer];
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer
{
    [recognizer.view becomeFirstResponder];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
    [menuController setMenuVisible:YES animated:YES];
}



@end

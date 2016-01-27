//
//  HipsterLabel.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 8. 26..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "HipsterLabel.h"

@implementation HipsterLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//text margin
-(void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0,5,0,5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

#pragma mark - UIResponderStandardEditActions
- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.text];
}


@end

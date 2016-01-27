//
//  PageContentViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 2. 25..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "Visual1_ViewController.h"
#import "Visual2_2_ViewController.h"

@interface PageContentViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIActivityIndicatorView *indicator;
    UIScrollView *scrollView;
    UIImageView *imageView;
    
    float gapX; //화면의 중간에 imageView를 위치하기 위해 이동해야할 X축 offset
}

@property FirstViewController *first;
@property Visual1_ViewController *visual1;
@property Visual2_2_ViewController *visual2_2;
@property NSUInteger pageIndex;
@property UIImage *image;
@property NSArray *pos_array;
@property NSMutableArray *ids_array;
@property NSArray *out_array;


@end

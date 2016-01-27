//
//  Visual1_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 11..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@interface Visual1_ViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    IBOutlet UIActivityIndicatorView *indicator;
    
    //result images
    int numOfImgs;
    NSMutableArray *img_array;
    NSMutableArray *pos_array;
    
    UIPageViewController *pageViewController;
    //page number
    IBOutlet UIPageControl *pageCtrl;
    IBOutlet UIView *pageView;
    IBOutlet UILabel *pageLabel;
    
    //Kakao
    BOOL isKakaoLogin;
}

@property FirstViewController *first;

//result data
@property NSArray *linkResult_array2;
@property NSString *linkName;

@property int pageIndex;    //현재 탭한 페이지 번호

@end

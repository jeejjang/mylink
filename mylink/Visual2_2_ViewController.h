//
//  Visual2_2_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 24..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@interface Visual2_2_ViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    IBOutlet UIActivityIndicatorView *indicator;
    
    //result images
    int numOfImgs;
    NSMutableArray *img_array;
    NSMutableArray *pos_array;
    NSMutableArray *id_array;
    NSMutableArray *out_array;
    
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
@property NSArray *linkResult_array2;   //결과가 없는 경우: 빈 배열 삽입
@property NSArray *linkNames_array2;
@property NSString *dup_id;

@property int pageIndex;    //현재 탭한 페이지 번호



@end

//
//  Visual2_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 24..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "ImageDownloader2.h"
#import "CellImageDownloader2.h"

@interface Visual2_ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ImageDownloader2>
{
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIScrollView *scrollView_visual2;
    UIImageView *imageView_visual2;
    
    int v[30];  //combination 계산에 사용되는 매개변수
    NSMutableArray *result_order;   //nCn-1 -> nC2(nCn, nC1 제외), 1부터 시작하는 배열(자신('1')은 생략)
    //중복된 노드 id 'set' 배열 (없으면 0개인 set)
    NSMutableArray *result_nodes1;  //nCn
    NSMutableArray *result_nodes2;  //nCn-1 -> nC2( (set,...),... )
    NSMutableArray *result_nodes3;  //nC1(set,...)
    //result position (없으면 0개인 array)
    NSMutableArray *pos_array1;    //nCn
    NSMutableArray *pos_array2;    //nCn-1 array -> nC2 array
    NSMutableArray *pos_array3;    //nC1(array,...)
    //result image
    NSMutableArray *resultImg_array;    //각 단계에 따른 전체 결과 이미지 
    UIImage *resultImg;                 //현재 보여지는 결과 이미지
    NSMutableDictionary *imagePool; //kakao images
    //NSMutableDictionary *rankPool;
    NSMutableArray *targetNum_array;    //선택한 타겟노드의 인덱스를 저장한 배열, 1부터 시작(자신('1')은 생략)
    CGPoint prePt;
    UIImage *img_not;
    BOOL isKakaoLogin; //Kakao
    
    
    //tableView_visual2
    UIButton *btn_del;
    UIImage *img_del;
    UITableView *tableView_visual2;
    NSMutableArray *tv_ids_array;   //중복 id 배열
    NSMutableArray *tv_relations_array;
    //NSMutableArray *tv_results_array; //나에서부터의 관계 배열(id_array,out_array,in_array)- 중복 id 포함
    //NSMutableArray *tv_ranks_array;
    NSMutableArray *outer_ids_array; //대상이 되는 outer id(NSString) 배열(나의 id는 포함되지 않음)
    NSMutableArray *outer_order_array;  //대상이 되는 outer order(NSString) 배열(나의 id는 포함되지 않음)
    //image download queue
    int tv_curI, tv_curJ; //현재 테이블뷰인지를 알기위한 매개변수
    NSOperationQueue *tv_downloaderQueue;
    NSMutableDictionary *tv_imagePool;
    
    
    //stepper
    UIStepper *stepper;
    
}

@property FirstViewController *first;

@property NSArray *linkResult_array2;
@property NSArray *linkNames_array2;




@end

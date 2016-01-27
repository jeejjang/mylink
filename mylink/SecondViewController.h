//
//  SecondViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 4..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"

@class FirstViewController;

@interface SecondViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UITableView *tableView_search;
    //IBOutlet UIActivityIndicatorView *indicator_search;
    
    //images
    UIImage *img_noresult;
    NSMutableDictionary *imagePool; //결과 썸네일 이미지(50x60)
    int imgNum; //이미지 번호
    
    //링크 검색
    IBOutlet UIView *view_search1; //링크 검색 외곽 전체 큰 화면
    IBOutlet UIView *view_search2; //링크 검색 화면
    IBOutlet UILabel *label_search;
    NSString *pre_string;   //UIPasteboard에 이전에 저장된 문자열
    
    //LongPress
    UILongPressGestureRecognizer *longPress;
    UIView *snapshot;
    NSIndexPath *sourceIndexPath;   //처음 선택한 셀의 indexPath
    NSIndexPath *indexPath_pre;
    //alertView 매개변수
    NSUInteger curIndex;    //현재 선택한 셀의 배열 인덱스
    NSUInteger sourceIndex; //처음 선택한 셀의 배열 인덱스
    int v[30];  //combination 계산에 사용되는 매개변수
    
    //링크 결과(8)
    NSMutableArray *linkSorts_array;    //"0":찾지 못한 경우 / "1":찾은 경우 / "3"~"5":함께 아는 관계
    NSMutableArray *linkResults_array;
    NSMutableArray *linkNames_array;    //검색대상 이름(또는 전화번호) 배열의 배열
    NSMutableArray *linkPhones_array;   //입력한 전화번호 배열의 배열
    NSMutableArray *linkIds_array;      //입력한 id 배열의 배열
    NSMutableArray *linkDates_array;    //검색한 날짜를 입력한 배열
    NSMutableArray *linkClicks_array;   //이미 클릭한 것은 "1" / 아직 클릭하지 않은 것은 "0"
    NSMutableArray *linkImgs_array;     //이미지 번호 저장(0부터, 없는 것은 -1)
    
    //새로운 링크 검색(매개변수)
    int index_update;   //결과 배열의 해당 인덱스
    
    //셀 분해
    IBOutlet UIView *view_minus;
    IBOutlet UIView *view_minus2;
    IBOutlet UIButton *btn_minusApply;
    IBOutlet UITableView *tableView_minus;
    NSUInteger minusArrayIndex; //선택한 배열의 index(테이블의 역순)
    NSMutableArray *minus_array; //name array
    NSMutableArray *minusDelIndex_array;    //제거한 minus_array의 인덱스 배열
    
}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator_search;

@property UITabBarController *tabbar;
@property FirstViewController *first;

//링크 검색
@property BOOL isSearching; //검색 중이면 YES

//input
@property (strong, nonatomic) IBOutlet UITextField *textField1;
@property NSString *phone1;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UIButton *btn_search2; // '검색' 버튼

//남은 시간 계산
@property (strong, nonatomic) IBOutlet UILabel *label_remainedTime; //남은 시간 표시 라벨
@property NSTimer *timer;
@property float remainedTime;

//링크 검색 횟수
@property UILabel *label_search;




//남은 시간 계산
-(void)updateCountdown;

//링크 검색
- (IBAction)searchBtnClicked:(id)sender;
- (IBAction)btn1Clicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)searchBtnClicked2:(id)sender; // '검색' 버튼

//편집
- (IBAction)editBtnClicked:(id)sender;

//셀 분해
- (IBAction)minusCancelClicked:(id)sender;
- (IBAction)minusApplyClicked:(id)sender;

//background fetch
//@property NSString *selectId_back;
-(void)reloadData_back;

//Remote Push
-(void)searchPushesThread;


@end

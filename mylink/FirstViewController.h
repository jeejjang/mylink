//
//  FirstViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 29..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "ImageDownloader.h"
#import "CellImageDownloader.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@class SecondViewController;
@class ThirdViewController;

@interface FirstViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchResultsUpdating, UISearchBarDelegate, ImageDownloader>
{
    UIAlertView *alert_main;    //"주소록 동기화 중입니다"
    UIProgressView *progress;
    
    //addressBook
    ABAddressBookRef addressBookRef;
    BOOL isAddressUpdating;
    NSString *kakao_loginDate; //kakao login 확인 시간
    
    //tableView
    NSArray *sectionTitles;
    NSMutableArray *sectionIndexTitles;
    
    //textField
    //BOOL isTextField;
    NSIndexPath *indexPath_textField;
    //UIEdgeInsets curInsets; //현재 tableView의 insets
    NSString *curText;
    
    //searchBar
    UISearchController *searchController;
    //BOOL isSearching;
    NSMutableArray *searchResults_keys;
    NSMutableDictionary *searchResultDic_key;
    NSMutableDictionary *searchResultDic_num;
    
    //thumbnail image
    NSOperationQueue *downloaderQueue;
    UIImage *empty_img;
}

@property UITabBarController *tabbar;

//Me
@property long myid; //나의 myLink ID
@property NSString *myPhone; //나의 전화번호
@property BOOL isFirst; //앱을 설치하고 처음 실행하는가?
@property BOOL isKakaoLogin;  //kakao 계정에 로그인이 되어있는가?
@property NSString *kakao_myUpdateDate; //my kakao updated date
@property NSString *myKakaoUrl; //my thumbnail image URL
@property BOOL isThumbUpdate;   //나의 thumbnail 이미지를 업데이트 할 것인가?
@property NSMutableDictionary *imagePool;   //thumbnail image pool
@property int rank; //나의 관계지수
@property int node; //내가 가지고 있는 노드 개수
@property int maxSearchNum; //최대 검색 횟수
@property int curSearchNum; //현재 남은 검색 횟수
@property NSDate *searchNumSavedDate; //검색 횟수가 변경된 date
@property NSTimer *timer_search; //1시간이 지나면 검색횟수를 증가시키는 타이머
//@property BOOL isTimer; //검색횟수 증가 타이머가 작동하고 있는가?
@property SecondViewController *second;
@property ThirdViewController *third;

//data(5)- (각 초성별 dictionary) / all NSString type
@property NSMutableDictionary *name_dic;
@property NSMutableDictionary *phone_dic;
@property NSMutableDictionary *relationName_dic;
@property NSMutableDictionary *myLinkID_dic;
@property NSMutableDictionary *kakao_dic; //logout:0 / login:URL  => save x

//data(6)- "새로 추가된 관계"
@property NSMutableArray *date_new;
@property NSMutableArray *name_new;
@property NSMutableArray *phone_new;
@property NSMutableArray *relationName_new;
@property NSMutableArray *myLinkID_new;
@property NSMutableArray *kakao_new;    // => save x

//data(3)- 숨김관계
@property NSMutableArray *name_hidden;
@property NSMutableArray *phone_hidden;
@property NSMutableArray *myLinkID_hidden;



//HiddenViewController에서 숨김관계가 보임으로 바뀔 때
-(void)addRelationInFirst:(NSString *)name forPhone:(NSString *)phone forId:(NSString *)myLinkID forLogin:(NSString *)login forIndex:(NSUInteger)curIndex;
- (IBAction)hiddenBtnClicked:(id)sender;
- (IBAction)ManageBtnClicked:(id)sender;

//검색횟수 증가 함수
-(void)searchNumRefresh;
-(void)performTimerOnMainThread:(NSNumber *)timer;



@end

//
//  UserInfo_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "CellImageDownloader.h"
#import "FirstViewController.h"

@class FirstViewController;

@interface UserInfo_ViewController : UIViewController<UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ImageDownloader>
{
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UITableView *info_tableView;
    
    long myid;
    BOOL isKakaoLogin; //나의 카카오 로그인 유무
    BOOL isKakaoLogin2; //상대방의 카카오 로그인 유무
    
    //kakao data
    NSString *updateddate;
    BOOL isTalk;
    NSString *talk_nickname;
    NSString *talk_proimg;
    BOOL isStory;
    NSString *story_url;
    NSString *story_nickname;
    NSString *story_proimg;
    NSString *story_birth;
    int story_birthtype;
    NSString *story_bgimg;
    BOOL isStoryPost;
    NSString *story_content;
    NSMutableArray *story_mediaimgs;
    NSString *story_date;
    
    //image download queue
    NSOperationQueue *downloaderQueue;
    NSMutableDictionary *imagePool;
    UIImage *empty_person;

}


//connection variables
@property FirstViewController *first;
@property int flag;   //0:내 자신, 1:주소록 안에 있는 사람, 2:기타
@property long user_id; //다른 사람의 myLink의 id

//1==flag || 2==flag 인 경우에
@property NSString *phone;
@property NSString *name;
@property NSString *relationName; //1==flag에만


@end

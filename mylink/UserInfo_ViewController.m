//
//  UserInfo_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "UserInfo_ViewController.h"
#import "InfoCell.h"
#import "InfoCell0.h"
#import "InfoCell1.h"
#import "InfoCell2.h"
#import "UserInfoImgZoom_ViewController.h"
#import "BlindSMSViewController.h"
#import "IntroViewController.h"

#define URL1 @"http://jeejjang.cafe24.com/link/kakao_update1.jsp?id=%ld&up_date='%@'&t_nick='%@'&t_proimg='%@'&t_thumb='%@'"
#define URL2 @"http://jeejjang.cafe24.com/link/kakao_update2_1.jsp?id=%ld&up_date='%@'&s_nick='%@'&s_birth='%@'&s_birthtype=%d&s_proimg='%@'&s_thumb='%@'&s_bgimg='%@'&s_url='%@'"
#define URL3 @"http://jeejjang.cafe24.com/link/kakao_update3.jsp?id=%ld&up_date='%@'&s_content='%@'&s_mediaimgs='%@'&s_date='%@'"
#define URL4 @"http://jeejjang.cafe24.com/link/kakao_check.jsp?id=%ld"
#define URL5 @"http://jeejjang.cafe24.com/link/kakao_info2.jsp?id=%ld"
#define URL6 @"http://jeejjang.cafe24.com/link/kakao_logout.jsp?id=%ld"



@interface UserInfo_ViewController ()
-(void)updateMyKakaoInfo;
-(void)updateKakaoInfo;
-(void)updateMyKakaoInfo_data;
-(NSString *)stringByReplacingforJSON:(NSString *)str;
-(InfoCell *)makeCell_B;
-(InfoCell *)makeCell;
-(InfoCell *)makeCell_2:(NSString *)str;
-(InfoCell0 *)makeCell0;
-(UITableViewCell *)makeCell1;
-(InfoCell1 *)makeCell2:(NSIndexPath *)indexPath;
-(InfoCell1 *)makeCell3:(NSIndexPath *)indexPath;
-(InfoCell2 *)makeCell4;
-(InfoCell2 *)makeCell5:(NSIndexPath *)indexPath;
-(void)webBtnClicked:(id)sender;
-(void)imageViewTapped_talk:(UITapGestureRecognizer *)gesture;
-(void)imageViewTapped_story:(UITapGestureRecognizer *)gesture;
-(void)imageViewTapped_story2:(UITapGestureRecognizer *)gesture;
-(void)logoutClicked:(id)sender;
-(void)logoutPerform;
-(void)logoutPerformThread;
-(void)reloadCellImage:(NSIndexPath *)indexPath;
-(void)invokeBlindWithTarget:(id)sender;
-(void)invokeLoginWithTarget:(id)sender;
@end

@implementation UserInfo_ViewController
@synthesize first, flag, user_id, name, relationName, phone;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"정 보";
    //tableView
    info_tableView.delegate = self;
    info_tableView.dataSource = self;
    //logoutButton
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"로그아웃" style:UIBarButtonItemStylePlain target:self action:@selector(logoutClicked:)];
    //image
    empty_person = [UIImage imageNamed:@"empty"];
    //image queue
    downloaderQueue = [[NSOperationQueue alloc] init];
    imagePool = [NSMutableDictionary dictionary];
    //init
    myid = first.myid;
    isKakaoLogin = first.isKakaoLogin;
    updateddate = nil;
    isTalk = NO;
    talk_nickname = nil;
    talk_proimg = nil;
    isStory = NO;
    story_url = nil;
    story_nickname = nil;
    story_birth = nil;
    story_birthtype = 0;
    story_proimg = nil;
    story_bgimg = nil;
    isStoryPost = NO;
    story_content = nil;
    story_date = nil;
    story_mediaimgs = [NSMutableArray array];
    if(0==flag)
    {
        if(isKakaoLogin)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;    //logoutButton
            [self updateMyKakaoInfo];
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;    //logoutButton
            [info_tableView reloadData];
        }
    }
    else //1==flag || 2==flag
    {
        if(isKakaoLogin)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;   //logoutButton
            //isKakaoLogin2
            NSString *temp = [NSString stringWithFormat:URL4, user_id];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                if(1==[[result objectForKey:@"login"] intValue])
                {
                    isKakaoLogin2 = YES;
                    [indicator startAnimating];
                    [NSThread detachNewThreadSelector:@selector(updateKakaoInfo) toTarget:self withObject:nil];
                }
                else
                {
                    isKakaoLogin2 = NO;
                    [info_tableView reloadData];
                }
            }
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;    //logoutButton
            [info_tableView reloadData];
        }
    }
}












-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [info_tableView setContentInset:UIEdgeInsetsZero];
    [info_tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}










//Kakao update
-(void)updateMyKakaoInfo //내 카카오 정보 업데이트
{
    [info_tableView reloadData];
    //my kakao updated date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *str= [formatter stringFromDate:date];
    first.kakao_myUpdateDate = [NSString stringWithString:str];
    //카카오에서 내 프로필 정보를 받아온다
    //(1)updated date
    updateddate = [NSString stringWithString:str];
    [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //(2)KakaoTalk profile
    [KOSessionTask talkProfileTaskWithCompletionHandler:^(KOTalkProfile* result, NSError* error)
    {
         if(result)
         {
             isTalk = YES;
             talk_nickname = [NSString stringWithString:result.nickName];
             talk_proimg = [NSString stringWithString:result.profileImageURL];
             [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update1) toTarget:self withObject:nil];
             NSString *talk_nickname2 = [self stringByReplacingforJSON:talk_nickname];
             NSString *talk_proimg2 = [[[talk_proimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *talk_thumb = [[[result.thumbnailURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL1, myid, updateddate, talk_nickname2, talk_proimg2, talk_thumb];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             //thumbnail image update
             if(isKakaoLogin) first.isThumbUpdate = YES;
         }
         else
         {
             isTalk = NO;
             [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
         }
    }];
    //(3)KakaoStory profile
    [KOSessionTask storyProfileTaskWithCompletionHandler:^(KOStoryProfile* profile, NSError* error)
    {
         if(profile)
         {
             isStory = YES;
             story_nickname = [NSString stringWithString:profile.nickName];
             story_birth = [NSString stringWithString:profile.birthday];
             story_birthtype = profile.birthdayType;
             story_proimg = [NSString stringWithString:profile.profileImageURL];
             story_bgimg = [NSString stringWithString:profile.bgImageURL];
             story_url = [NSString stringWithString:profile.permalink];
             [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update2) toTarget:self withObject:nil];
             NSString *story_nickname2 = [self stringByReplacingforJSON:story_nickname];
             NSString *story_proimg2 = [[[story_proimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_bgimg2 = [[[story_bgimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_thumb = [[[profile.thumbnailURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_url2 = [[[story_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL2, myid, updateddate, story_nickname2, story_birth, story_birthtype, story_proimg2, story_thumb, story_bgimg2, story_url2];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             //thumbnail image update
             if(isKakaoLogin) first.isThumbUpdate = YES;
         }
         else
         {
             isStory = NO;
             [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
         }
    }];
    //(4)Last story post
    [KOSessionTask storyGetMyStoriesTaskWithLastMyStoryId:nil completionHandler:^(NSArray *myStories, NSError *error)
    {
         if (!error)
         {
             isStoryPost = NO;
             for (KOStoryMyStoryInfo *myStory in myStories)
             {
                 if(0==myStory.permission || 1==myStory.permission)
                 {
                     isStoryPost = YES;
                     story_content = [NSString stringWithString:myStory.content];
                     //3:사진이 함께 있는 경우
                     if(3==myStory.mediaType)
                     {
                         for(KOStoryMyStoryImageInfo *imgInfo in myStory.media)
                         {
                             [story_mediaimgs addObject:[NSString stringWithString:imgInfo.original]];
                         }
                     }
                     story_date = [NSString stringWithString:myStory.createdAt];
                     break;
                 }
             }
             if(isStoryPost)
             {
                 [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                 //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                 //server upload(NSThread)
                 //[NSThread detachNewThreadSelector:@selector(kakao_update3) toTarget:self withObject:nil];
                 NSMutableString *temp1 = [NSMutableString stringWithString:@""];
                 int cnt = (int)[story_mediaimgs count];
                 if(cnt > 0)
                 {
                     int num1 = cnt/10;
                     int num2 = cnt - num1*10;
                     [temp1 appendFormat:@"%d%d", num1, num2];
                     int num3, cnt2;
                     for(NSString *str in story_mediaimgs)
                     {
                         cnt2 = (int)[str length];
                         num1 = cnt2/100;
                         num2 = (cnt2 - num1*100)/10;
                         num3 = cnt2 - num1*100 - num2*10;
                         [temp1 appendFormat:@"%d%d%d", num1, num2, num3];
                         [temp1 appendString:[[[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];
                     }
                 }
                 NSString *story_content2 = [self stringByReplacingforJSON:story_content];
                 NSString *temp = [NSString stringWithFormat:URL3, myid, updateddate, story_content2, temp1, story_date];
                 [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             }
         }
         else
         {
             isStoryPost = NO;
             [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             //[info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
         }
    }];
}
-(NSString *)stringByReplacingforJSON:(NSString *)str
{
    NSString *str2 = [[[[[[[str  stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\\n"] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\\\""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return [NSString stringWithString:str2];
}
-(void)updateMyKakaoInfo_data
{
    //my kakao updated date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *str= [formatter stringFromDate:date];
    first.kakao_myUpdateDate = [NSString stringWithString:str];
    //카카오에서 내 프로필 정보를 받아온다
    //(1)updated date
    NSString *updateddate2 = [NSString stringWithString:str];
    //(2)KakaoTalk profile
    [KOSessionTask talkProfileTaskWithCompletionHandler:^(KOTalkProfile* result, NSError* error)
    {
         if(result)
         {
             NSString *talk_nickname2 = [NSString stringWithString:result.nickName];
             NSString *talk_proimg2 = [NSString stringWithString:result.profileImageURL];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update1_data:) toTarget:self withObject:[NSArray arrayWithObjects:updateddate2, talk_nickname2, talk_proimg2, nil]];
             NSString *talk_nickname3 = [self stringByReplacingforJSON:talk_nickname2];
             NSString *talk_proimg3 = [[[talk_proimg2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *talk_thumb = [[[result.thumbnailURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL1, myid, updateddate2, talk_nickname3, talk_proimg3, talk_thumb];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             //thumbnail image update
             if(isKakaoLogin) first.isThumbUpdate = YES;
         }
    }];
    //(3)KakaoStory profile
    [KOSessionTask storyProfileTaskWithCompletionHandler:^(KOStoryProfile* profile, NSError* error)
    {
         if(profile)
         {
             NSString *story_nickname2 = [NSString stringWithString:profile.nickName];
             NSString *story_birth2 = [NSString stringWithString:profile.birthday];
             int story_birthtype2 = profile.birthdayType;
             NSString *story_proimg2 = [NSString stringWithString:profile.profileImageURL];
             NSString *story_bgimg2 = [NSString stringWithString:profile.bgImageURL];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update2_data:) toTarget:self withObject:[NSArray arrayWithObjects:updateddate2, story_nickname2, story_birth2, [NSNumber numberWithInt:story_birthtype2], story_proimg2, story_bgimg2, nil]];
             NSString *story_nickname3 = [self stringByReplacingforJSON:story_nickname2];
             NSString *story_proimg3 = [[[story_proimg2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_bgimg3 = [[[story_bgimg2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_thumb = [[[profile.thumbnailURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_url2 = [[[profile.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL2, myid, updateddate2, story_nickname3, story_birth2, story_birthtype2, story_proimg3, story_thumb, story_bgimg3, story_url2];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             //thumbnail image update
             if(isKakaoLogin) first.isThumbUpdate = YES;
         }
    }];
    //(4)Last story post
    [KOSessionTask storyGetMyStoriesTaskWithLastMyStoryId:nil completionHandler:^(NSArray *myStories, NSError *error)
    {
         NSMutableArray *story_mediaimgs2 = [NSMutableArray array];
         NSString *story_content2 = nil;
         NSString *story_date2 = nil;
         if (!error)
         {
             BOOL isStoryPost2 = NO;
             for (KOStoryMyStoryInfo *myStory in myStories)
             {
                 if(0==myStory.permission || 1==myStory.permission)
                 {
                     isStoryPost2 = YES;
                     story_content2 = [NSString stringWithString:myStory.content];
                     //3:사진이 함께 있는 경우
                     if(3==myStory.mediaType)
                     {
                         for(KOStoryMyStoryImageInfo *imgInfo in myStory.media)
                         {
                             [story_mediaimgs2 addObject:[NSString stringWithString:imgInfo.original]];
                         }
                     }
                     story_date2 = [NSString stringWithString:myStory.createdAt];
                     break;
                 }
             }
             if(isStoryPost2)
             {
                 //server upload(NSThread)
                 //[NSThread detachNewThreadSelector:@selector(kakao_update3_data:) toTarget:self withObject:[NSArray arrayWithObjects:updateddate2, story_content2, story_date2, story_mediaimgs2, nil]];
                 NSMutableString *temp1 = [NSMutableString stringWithString:@""];
                 //NSArray *story_mediaimgs2 = [NSArray arrayWithArray:[array objectAtIndex:3]];
                 int cnt = (int)[story_mediaimgs2 count];
                 if(cnt > 0)
                 {
                     int num1 = cnt/10;
                     int num2 = cnt - num1*10;
                     [temp1 appendFormat:@"%d%d", num1, num2];
                     int num3, cnt2;
                     for(NSString *str in story_mediaimgs2)
                     {
                         cnt2 = (int)[str length];
                         num1 = cnt2/100;
                         num2 = (cnt2 - num1*100)/10;
                         num3 = cnt2 - num1*100 - num2*10;
                         [temp1 appendFormat:@"%d%d%d", num1, num2, num3];
                         [temp1 appendString:[[[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];
                     }
                 }
                 NSString *story_content3 = [self stringByReplacingforJSON:story_content2];
                 NSString *temp = [NSString stringWithFormat:URL3, myid, updateddate2, story_content3, temp1, story_date2];
                 [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             }
         }
    }];
}
-(void)updateKakaoInfo
{
    NSString *temp = [NSString stringWithFormat:URL5, user_id];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if([[result objectForKey:@"result"] isEqualToString:@"1"])
        {
            //updatedate
            if(![[result objectForKey:@"up_date"] isEqualToString:@"null"])
            {
                updateddate = [NSString stringWithString:[result objectForKey:@"up_date"]];
            }
            //kakao_talk
            if(![[result objectForKey:@"t_proimg"] isEqualToString:@"null"])
            {
                isTalk = YES;
                talk_nickname = [NSString stringWithString:[result objectForKey:@"t_nick"]];
                talk_proimg = [NSString stringWithString:[result objectForKey:@"t_proimg"]];
            }
            else
            {
                isTalk = NO;
            }
            //kakao_story
            if(![[result objectForKey:@"s_proimg"] isEqualToString:@"null"])
            {
                isStory = YES;
                story_nickname = [NSString stringWithString:[result objectForKey:@"s_nick"]];
                story_birth = [NSString stringWithString:[result objectForKey:@"s_birth"]];
                story_birthtype = [[NSString stringWithString:[result objectForKey:@"s_birthtype"]] intValue];
                story_proimg = [NSString stringWithString:[result objectForKey:@"s_proimg"]];
                story_bgimg = [NSString stringWithString:[result objectForKey:@"s_bgimg"]];
                story_url = [NSString stringWithString:[result objectForKey:@"s_url"]];
            }
            else
            {
                isStory = NO;
            }
            //kakao_story_post
            if(![[result objectForKey:@"s_mediaimgs"] isEqualToString:@"null"])
            {
                isStoryPost = YES;
                story_content = [NSString stringWithString:[result objectForKey:@"s_content"]];
                story_date = [NSString stringWithString:[result objectForKey:@"s_date"]];
                NSString *temp = [NSString stringWithString:[result objectForKey:@"s_mediaimgs"]];
                int temp_length = (int)[temp length];
                if([temp length] > 2)
                {
                    int numOfImg = [[temp substringWithRange:NSMakeRange(0, 2)] intValue];
                    int index = 1;
                    int temp_num;
                    for(int i=0; i<numOfImg; i++)
                    {
                        if(index+3 > temp_length-1) break;
                        temp_num = [[temp substringWithRange:NSMakeRange(index+1, 3)] intValue];
                        index += 3;
                        if(index+temp_num > temp_length-1) break;
                        [story_mediaimgs addObject:[temp substringWithRange:NSMakeRange(index+1, temp_num)]];
                        index += temp_num;
                    }
                }
            }
            else
            {
                isStoryPost = NO;
            }
        }
    }
    else
    {
        updateddate = nil;
        isTalk = NO;
        isStory = NO;
        isStoryPost = NO;
    }
    [info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [indicator stopAnimating];
}























//tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView2 heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0==flag)
    {
        if(isKakaoLogin) return 4;
        else return 1;
    }
    else if(1==flag)
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2) return 6;
            else return 3;
        }
        else return 3;
    }
    else
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2) return 5;
            else return 2;
        }
        else return 2;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0==flag)
    {
        if(isKakaoLogin)
        {
            if(0==indexPath.row) return 25.0f;
            else if(1==indexPath.row)
            {
                if(isTalk) return 190.0f;
                else return 20.0f;
            }
            else if(2==indexPath.row)
            {
                if(isStory) return 250.0f;
                else return 20.0f;
            }
            else
            {
                if(isStoryPost)
                {
                    if([story_mediaimgs count]>0)
                    {
                        CGSize maxSize = CGSizeMake(290, 10000);
                        UIFont *font = [UIFont systemFontOfSize:13];
                        CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                        return dataRect.size.height+318.0f;
                    }
                    else
                    {
                        CGSize maxSize = CGSizeMake(290, 10000);
                        UIFont *font = [UIFont systemFontOfSize:13];
                        CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                        return dataRect.size.height+98.0f;
                    }
                }
                else return 20.0f;
            }
        }
        else return 200.0f;
    }
    else if(1==flag)
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2)
            {
                if(0==indexPath.row) return 85.0f;
                else if(1==indexPath.row) return 100.0f;
                else if(2==indexPath.row) return 25.0f;
                else if(3==indexPath.row)
                {
                    if(isTalk) return 190.0f;
                    else return 20.0f;
                }
                else if(4==indexPath.row)
                {
                    if(isStory) return 250.0f;
                    else return 20.0f;
                }
                else
                {
                    if(isStoryPost)
                    {
                        if([story_mediaimgs count]>0)
                        {
                            CGSize maxSize = CGSizeMake(290, 10000);
                            UIFont *font = [UIFont systemFontOfSize:13];
                            CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                            return dataRect.size.height+318.0f;
                        }
                        else
                        {
                            CGSize maxSize = CGSizeMake(290, 10000);
                            UIFont *font = [UIFont systemFontOfSize:13];
                            CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                            return dataRect.size.height+98.0f;
                        }
                    }
                    else return 20.0f;
                }
            }
            else
            {
                if(0==indexPath.row) return 85.0f;
                else if(1==indexPath.row) return 100.0f;
                else return 80.0f;
            }
        }
        else
        {
            if(0==indexPath.row) return 85.0f;
            else if(1==indexPath.row) return 100.0f;
            else return 200.0f;
        }
    }
    else //2==flag
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2)
            {
                if(0==indexPath.row) return 100.0f;
                else if(1==indexPath.row) return 25.0f;
                else if(2==indexPath.row)
                {
                    if(isTalk) return 190.0f;
                    else return 20.0f;
                }
                else if(3==indexPath.row)
                {
                    if(isStory) return 250.0f;
                    else return 20.0f;
                }
                else
                {
                    if(isStoryPost)
                    {
                        if([story_mediaimgs count]>0)
                        {
                            CGSize maxSize = CGSizeMake(290, 10000);
                            UIFont *font = [UIFont systemFontOfSize:13];
                            CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                            return dataRect.size.height+318.0f;
                        }
                        else
                        {
                            CGSize maxSize = CGSizeMake(290, 10000);
                            UIFont *font = [UIFont systemFontOfSize:13];
                            CGRect dataRect = [story_content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
                            return dataRect.size.height+98.0f;
                        }
                    }
                    else return 20.0f;
                }
            }
            else
            {
                if(0==indexPath.row) return 100.0f;
                else return 80.0f;
            }
        }
        else
        {
            if(0==indexPath.row) return 100.0f;
            else return 200.0f;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0==flag)
    {
        if(isKakaoLogin)
        {
            if(0==indexPath.row)
            {
                UITableViewCell *cell = [self makeCell1];
                return cell;
            }
            else if(1==indexPath.row)
            {
                if(isTalk)
                {
                    InfoCell1 *cell = [self makeCell2:indexPath];
                    return cell;
                }
                else
                {
                    InfoCell *cell = [self makeCell_2:@"카카오톡 프로필이 없습니다"];
                    return cell;
                }
            }
            else if(2==indexPath.row)
            {
                if(isStory)
                {
                    InfoCell1 *cell = [self makeCell3:indexPath];
                    return cell;
                }
                else
                {
                    InfoCell *cell = [self makeCell_2:@"카카오스토리 프로필이 없습니다"];
                    return cell;
                }
            }
            else
            {
                if(isStoryPost)
                {
                    if([story_mediaimgs count]>0)
                    {
                        InfoCell2 *cell = [self makeCell5:indexPath];
                        return cell;
                    }
                    else
                    {
                        InfoCell2 *cell = [self makeCell4];
                        return cell;
                    }
                }
                else
                {
                    InfoCell *cell = [self makeCell_2:@"카카오스토리 포스트가 없습니다"];
                    return cell;
                }
            }
        }
        else
        {
            InfoCell *cell = [self makeCell];
            return cell;
        }
    }
    else if(1==flag)
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2)
            {
                if(0==indexPath.row)
                {
                    InfoCell0 *cell = [self makeCell0];
                    return cell;
                }
                else if(1==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell_B];
                    return cell;
                }
                else if(2==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell1];
                    return cell;
                }
                else if(3==indexPath.row)
                {
                    if(isTalk)
                    {
                        InfoCell1 *cell = [self makeCell2:indexPath];
                        return cell;
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오톡 프로필이 없습니다"];
                        return cell;
                    }
                }
                else if(4==indexPath.row)
                {
                    if(isStory)
                    {
                        InfoCell1 *cell = [self makeCell3:indexPath];
                        return cell;
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오스토리 프로필이 없습니다"];
                        return cell;
                    }
                }
                else
                {
                    if(isStoryPost)
                    {
                        if([story_mediaimgs count]>0)
                        {
                            InfoCell2 *cell = [self makeCell5:indexPath];
                            return cell;
                        }
                        else
                        {
                            InfoCell2 *cell = [self makeCell4];
                            return cell;
                        }
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오스토리 포스트가 없습니다"];
                        return cell;
                    }
                }
            }
            else
            {
                if(0==indexPath.row)
                {
                    InfoCell0 *cell = [self makeCell0];
                    return cell;
                }
                else if(1==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell_B];
                    return cell;
                }
                else
                {
                    InfoCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL_1"];
                    return cell;
                }
            }
        }
        else
        {
            if(0==indexPath.row)
            {
                InfoCell0 *cell = [self makeCell0];
                return cell;
            }
            else if(1==indexPath.row)
            {
                UITableViewCell *cell = [self makeCell_B];
                return cell;
            }
            else
            {
                InfoCell *cell = [self makeCell];
                return cell;
            }
        }
    }
    else
    {
        if(isKakaoLogin)
        {
            if(isKakaoLogin2)
            {
                if(0==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell_B];
                    return cell;
                }
                else if(1==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell1];
                    return cell;
                }
                else if(2==indexPath.row)
                {
                    if(isTalk)
                    {
                        InfoCell1 *cell = [self makeCell2:indexPath];
                        return cell;
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오톡 프로필이 없습니다"];
                        return cell;
                    }
                }
                else if(3==indexPath.row)
                {
                    if(isStory)
                    {
                        InfoCell1 *cell = [self makeCell3:indexPath];
                        return cell;
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오스토리 프로필이 없습니다"];
                        return cell;
                    }
                }
                else
                {
                    if(isStoryPost)
                    {
                        if([story_mediaimgs count]>0)
                        {
                            InfoCell2 *cell = [self makeCell5:indexPath];
                            return cell;
                        }
                        else
                        {
                            InfoCell2 *cell = [self makeCell4];
                            return cell;
                        }
                    }
                    else
                    {
                        InfoCell *cell = [self makeCell_2:@"카카오스토리 포스트가 없습니다"];
                        return cell;
                    }
                }
            }
            else
            {
                if(0==indexPath.row)
                {
                    UITableViewCell *cell = [self makeCell_B];
                    return cell;
                }
                else
                {
                    InfoCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL_1"];
                    return cell;
                }
            }
        }
        else
        {
            if(0==indexPath.row)
            {
                UITableViewCell *cell = [self makeCell_B];
                return cell;
            }
            else
            {
                InfoCell *cell = [self makeCell];
                return cell;
            }
        }
    }
}















//cell methods
-(InfoCell *)makeCell
{
    InfoCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL"];
    //kakao login button
    if(!cell.kakaoLoginButton)
    {
        cell.kakaoLoginButton = [[KOLoginButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260.0f)/2.0f, 150.0f, 260.0f, 42.0f)];
        
        [cell.contentView addSubview:cell.kakaoLoginButton];
        [cell.kakaoLoginButton addTarget:self action:@selector(invokeLoginWithTarget:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
-(InfoCell *)makeCell_2:(NSString *)str
{
    InfoCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL_2"];
    //cell.cell_label.text = str;
    return cell;
}
-(InfoCell *)makeCell_B
{
    InfoCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL_B"];
    [cell.btn_blind addTarget:self action:@selector(invokeBlindWithTarget:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(InfoCell0 *)makeCell0
{
    InfoCell0 *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL0"];
    cell.cell_label1.text = name;
    cell.cell_label2.text = relationName;
    cell.cell_label3.text = phone;
    return cell;
}
-(UITableViewCell *)makeCell1
{
    UITableViewCell *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL1"];
    if(nil==cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"INFOCELL1"];
    if(updateddate) cell.textLabel.text = [NSString stringWithFormat:@"%@년 %@월 %@일에 업데이트됨",[updateddate substringWithRange:NSMakeRange(0, 4)], [updateddate substringWithRange:NSMakeRange(4, 2)], [updateddate substringWithRange:NSMakeRange(6, 2)]];
    return cell;
}
-(InfoCell1 *)makeCell2:(NSIndexPath *)indexPath
{
    InfoCell1 *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL2"];
    if(isTalk)
    {
        cell.cell_label.text = talk_nickname;
        if(talk_proimg && ![talk_proimg isEqualToString:@""])
        {
            NSNumber *num = [NSNumber numberWithInt:1];
            UIImage *image = [imagePool objectForKey:num];
            if([image isMemberOfClass:[UIImage class]]) cell.cell_imageView.image = image;
            else if(nil==image)
            {
                CellImageDownloader *down = [[CellImageDownloader alloc] init];
                down.delegate2 = self;
                down.urlStr = talk_proimg;
                down.indexPath = indexPath;
                down.num = num;
                [downloaderQueue addOperation:down];
                [imagePool setObject:[NSNull null] forKey:num];
            }
            //tap gesture
            UITapGestureRecognizer *tap_talk = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped_talk:)];
            [cell.cell_imageView addGestureRecognizer:tap_talk];
        }
        else
        {
            cell.cell_imageView.image = empty_person;
        }
    }
    return cell;
}
-(InfoCell1 *)makeCell3:(NSIndexPath *)indexPath
{
    InfoCell1 *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL3"];
    if(isStory)
    {
        NSMutableString *temp = [NSMutableString stringWithString:story_nickname];
        if(story_url && story_url.length!=0 && ![story_url isEqualToString:@"null"])
        {
            cell.cell_webBtn.hidden = NO;
            //click event
            [cell.cell_webBtn addTarget:self action:@selector(webBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.cell_webBtn.hidden = YES;
        }
        if(story_birth && ![story_birth isEqualToString:@""])
        {
            NSString *temp2 = [NSString stringWithFormat:@"%@월 %@일", [story_birth substringToIndex:2], [story_birth substringFromIndex:2]];
            [temp appendString:@"("];
            [temp appendString:temp2];
            if(story_birthtype==0) [temp appendString:@", 양력)"];
            else [temp appendString:@", 음력)"];
        }
        cell.cell_label.text = temp;
        if(story_bgimg && ![story_bgimg isEqualToString:@""])
        {
            NSNumber *num = [NSNumber numberWithInt:2];
            UIImage *image = [imagePool objectForKey:num];
            if(!cell.cell_bg_imageView)
            {
                cell.cell_bg_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 170.0f)];
                [cell.cell_bg_scrollView addSubview:cell.cell_bg_imageView];
            }
            if([image isMemberOfClass:[UIImage class]])
            {
                cell.cell_bg_imageView.image = image;
            }
            else if(nil==image)
            {
                CellImageDownloader *down = [[CellImageDownloader alloc] init];
                down.delegate2 = self;
                down.urlStr = story_bgimg;
                down.indexPath = indexPath;
                down.num = num;
                [downloaderQueue addOperation:down];
                [imagePool setObject:[NSNull null] forKey:num];
            }
            else cell.cell_bg_imageView.image = nil;
        }
        if(story_proimg && ![story_proimg isEqualToString:@""])
        {
            NSNumber *num = [NSNumber numberWithInt:3];
            UIImage *image = [imagePool objectForKey:num];
            if([image isMemberOfClass:[UIImage class]]) cell.cell_imageView.image = image;
            else if(nil==image)
            {
                CellImageDownloader *down = [[CellImageDownloader alloc] init];
                down.delegate2 = self;
                down.urlStr = story_proimg;
                down.indexPath = indexPath;
                down.num = num;
                [downloaderQueue addOperation:down];
                [imagePool setObject:[NSNull null] forKey:num];
            }
            //tap gesture
            UITapGestureRecognizer *tap_story = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped_story:)];
            [cell.cell_imageView addGestureRecognizer:tap_story];
        }
        else
        {
            cell.cell_imageView.image = empty_person;
        }
    }
    return cell;
}
-(InfoCell2 *)makeCell4
{
    InfoCell2 *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL4"];
    if(isStoryPost)
    {
        cell.cell_content_label.text = story_content;
        NSMutableString *temp_str = [NSMutableString string];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(0,4)]];
        [temp_str appendString:@"."];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(5,2)]];
        [temp_str appendString:@"."];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(8,2)]];
        int temp_int = [[story_date substringWithRange:NSMakeRange(11,2)] intValue] + 9;
        if(temp_int/13 > 0) //13시~
        {
            [temp_str appendString:@" 오후 "];
            [temp_str appendString:[NSString stringWithFormat:@"%02d:%02d",temp_int-12,[[story_date substringWithRange:NSMakeRange(14,2)] intValue]]];
        }
        else
        {
            [temp_str appendString:@" 오전 "];
            [temp_str appendString:[NSString stringWithFormat:@"%02d:%02d",temp_int,[[story_date substringWithRange:NSMakeRange(14,2)] intValue]]];
        }
        cell.cell_date_label.text = temp_str;
    }
    return cell;
}
-(InfoCell2 *)makeCell5:(NSIndexPath *)indexPath
{
    InfoCell2 *cell = [info_tableView dequeueReusableCellWithIdentifier:@"INFOCELL5"];
    if(isStoryPost)
    {
        cell.cell_content_label.text = story_content;
        NSMutableString *temp_str = [NSMutableString string];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(0,4)]];
        [temp_str appendString:@"."];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(5,2)]];
        [temp_str appendString:@"."];
        [temp_str appendString:[story_date substringWithRange:NSMakeRange(8,2)]];
        int temp_int = [[story_date substringWithRange:NSMakeRange(11,2)] intValue] + 9;
        if(temp_int/13 > 0) //13시~
        {
            [temp_str appendString:@" 오후 "];
            [temp_str appendString:[NSString stringWithFormat:@"%02d:%02d",temp_int-12,[[story_date substringWithRange:NSMakeRange(14,2)] intValue]]];
        }
        else
        {
            [temp_str appendString:@" 오전 "];
            [temp_str appendString:[NSString stringWithFormat:@"%02d:%02d",temp_int,[[story_date substringWithRange:NSMakeRange(14,2)] intValue]]];
        }
        cell.cell_date_label.text = temp_str;
        cell.cell_scrollView.delegate = self;
        if(1==[story_mediaimgs count]) //center position
        {
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:40];
            if(imageView)
            {
                NSNumber *num = [NSNumber numberWithInt:4];
                UIImage *image = [imagePool objectForKey:num];
                if([image isMemberOfClass:[UIImage class]])
                {
                    imageView.image = image;
                }
                else if(nil==image)
                {
                    CellImageDownloader *down = [[CellImageDownloader alloc] init];
                    down.delegate2 = self;
                    down.urlStr = [story_mediaimgs objectAtIndex:0];
                    down.indexPath = indexPath;
                    down.num = num;
                    [downloaderQueue addOperation:down];
                    [imagePool setObject:[NSNull null] forKey:num];
                }
            }
            else
            {
                UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f-100.0f, 0.0f, 200.0f, 200.0f)];
                imageView2.tag = 40;
                [cell.cell_scrollView addSubview:imageView2];
                NSNumber *num = [NSNumber numberWithInt:4];
                UIImage *image = [imagePool objectForKey:num];
                if([image isMemberOfClass:[UIImage class]])
                {
                    imageView2.image = image;
                }
                else if(nil==image)
                {
                    CellImageDownloader *down = [[CellImageDownloader alloc] init];
                    down.delegate2 = self;
                    down.urlStr = [story_mediaimgs objectAtIndex:0];
                    down.indexPath = indexPath;
                    down.num = num;
                    [downloaderQueue addOperation:down];
                    [imagePool setObject:[NSNull null] forKey:num];
                }
            }
            cell.cell_scrollView.contentSize = CGSizeMake(self.view.frame.size.width/2.0f+100.0f, 200.0f);
        }
        else
        {
            CGFloat indexX = 60.0f;
            for(int i=0; i<[story_mediaimgs count]; i++)
            {
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:40+i];
                if(imageView)
                {
                    NSNumber *num = [NSNumber numberWithInt:4+i];
                    UIImage *image = [imagePool objectForKey:num];
                    if([image isMemberOfClass:[UIImage class]])
                    {
                        imageView.image = image;
                    }
                    else if(nil==image)
                    {
                        CellImageDownloader *down = [[CellImageDownloader alloc] init];
                        down.delegate2 = self;
                        down.urlStr = [story_mediaimgs objectAtIndex:i];
                        down.indexPath = indexPath;
                        down.num = num;
                        [downloaderQueue addOperation:down];
                        [imagePool setObject:[NSNull null] forKey:num];
                    }
                }
                else
                {
                    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(indexX, 0.0f, 200.0f, 200.0f)];
                    imageView2.tag = 40+i;
                    [cell.cell_scrollView addSubview:imageView2];
                    NSNumber *num = [NSNumber numberWithInt:4+i];
                    UIImage *image = [imagePool objectForKey:num];
                    if([image isMemberOfClass:[UIImage class]])
                    {
                        imageView2.image = image;
                    }
                    else if(nil==image)
                    {
                        CellImageDownloader *down = [[CellImageDownloader alloc] init];
                        down.delegate2 = self;
                        down.urlStr = [story_mediaimgs objectAtIndex:i];
                        down.indexPath = indexPath;
                        down.num = num;
                        [downloaderQueue addOperation:down];
                        [imagePool setObject:[NSNull null] forKey:num];
                    }
                }
                indexX += 210.0f;
            }
            cell.cell_scrollView.contentSize = CGSizeMake(indexX, 200.0f);
        }
        //tap gesture
        if([story_mediaimgs count] > 0)
        {
            UITapGestureRecognizer *tap_story2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped_story2:)];
            [cell.cell_scrollView addGestureRecognizer:tap_story2];
        }
    }
    return cell;
}













//Tap
-(void)webBtnClicked:(id)sender
{
    IntroViewController *intro = [self.storyboard instantiateViewControllerWithIdentifier:@"INTRO"];
    intro.str_url = story_url;
    [self presentViewController:intro animated:YES completion:nil];
}
-(void)imageViewTapped_talk:(UITapGestureRecognizer *)gesture
{
    UIImage *image = [imagePool objectForKey:[NSNumber numberWithInt:1]];
    if([image isMemberOfClass:[UIImage class]])
    {
        UserInfoImgZoom_ViewController *zoom = [self.storyboard instantiateViewControllerWithIdentifier:@"ZOOM"];
        zoom.image = image;
        //[self.navigationController pushViewController:zoom animated:YES];
        [self presentViewController:zoom animated:YES completion:nil];
    }
}
-(void)imageViewTapped_story:(UITapGestureRecognizer *)gesture
{
    UIImage *image = [imagePool objectForKey:[NSNumber numberWithInt:3]];
    if([image isMemberOfClass:[UIImage class]])
    {
        UserInfoImgZoom_ViewController *zoom = [self.storyboard instantiateViewControllerWithIdentifier:@"ZOOM"];
        zoom.image = image;
        //[self.navigationController pushViewController:zoom animated:YES];
        [self presentViewController:zoom animated:YES completion:nil];
    }
}
-(void)imageViewTapped_story2:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    if(1==[story_mediaimgs count]) //center position
    {
        float center_x = self.view.frame.size.width/2.0f;
        if((point.x>=center_x-100.0f) && (point.x<=center_x+100.0f))
        {
            UIImage *image = [imagePool objectForKey:[NSNumber numberWithInt:4]];
            if([image isMemberOfClass:[UIImage class]])
            {
                UserInfoImgZoom_ViewController *zoom = [self.storyboard instantiateViewControllerWithIdentifier:@"ZOOM"];
                zoom.image = image;
                //[self.navigationController pushViewController:zoom animated:YES];
                [self presentViewController:zoom animated:YES completion:nil];
            }
        }
    }
    else
    {
        int index = (int)((point.x-50.0f)/210.0f);
        if(index<0 || index>[story_mediaimgs count]-1) return;
        UIImage *image = [imagePool objectForKey:[NSNumber numberWithInt:4+index]];
        if([image isMemberOfClass:[UIImage class]])
        {
            UserInfoImgZoom_ViewController *zoom = [self.storyboard instantiateViewControllerWithIdentifier:@"ZOOM"];
            zoom.image = image;
            //[self.navigationController pushViewController:zoom animated:YES];
            [self presentViewController:zoom animated:YES completion:nil];
        }
    }
}














//<kakao API>
//Blind SMS
-(void)invokeBlindWithTarget:(id)sender
{
    BlindSMSViewController *blind = [self.storyboard instantiateViewControllerWithIdentifier:@"BLIND"];
    blind.first = first;
    if(1==flag)
    {
        blind.flag = 0;
        blind.phone_receiver = [NSString stringWithString:phone];
        blind.text_receiver = [NSString stringWithFormat:@"%@(%@)", name, phone];
    }
    else //2==flag
    {
        blind.flag = 1;
        blind.phone_receiver = [NSString stringWithString:phone];
        blind.text_receiver = [NSString stringWithFormat:@"%@", name];
    }
    [self presentViewController:blind animated:YES completion:nil];
}
//Login Button Clicked
-(void)invokeLoginWithTarget:(id)sender
{
    // ensure old session was closed
    [[KOSession sharedSession] close];
    [[KOSession sharedSession] openWithCompletionHandler:^(NSError *error)
    {
         if ([[KOSession sharedSession] isOpen]) // login success
         {
             isKakaoLogin = YES;
             first.isKakaoLogin = YES;
             if(0==flag)
             {
                 self.navigationItem.rightBarButtonItem.enabled = YES;   //logoutButton
                 [self updateMyKakaoInfo];
             }
             else   //1==flag || 2==flag
             {
                 self.navigationItem.rightBarButtonItem.enabled = YES;   //logoutButton
                 //isKakaoLogin2
                 NSString *temp = [NSString stringWithFormat:URL4, user_id];
                 id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                 if(result)
                 {
                     if(1==[[result objectForKey:@"login"] intValue])
                     {
                         isKakaoLogin2 = YES;
                         [indicator startAnimating];
                         [NSThread detachNewThreadSelector:@selector(updateKakaoInfo) toTarget:self withObject:nil];
                     }
                     else
                     {
                         isKakaoLogin2 = NO;
                         [info_tableView reloadData];
                     }
                 }
                 //Refresh my data
                 [self updateMyKakaoInfo_data];
             }
         }
         else // failed
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"잠시 후에 다시 시도해 주세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
             [alert show];
         }
    }];
}
//Logout Button Clicked
-(void)logoutClicked:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"로그아웃 하시겠습니까?" message:@"로그아웃을 하면 다른사람의 카카오 정보를 볼 수 없습니다" delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
    [alert show];
    //->logoutPerform
}
-(void)logoutPerform
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.backBarButtonItem.enabled = NO;
    [[KOSession sharedSession] logoutAndCloseWithCompletionHandler:^(BOOL success, NSError *error)
    {
         if(success)
         {
             first.isKakaoLogin = NO;
             first.myKakaoUrl = @"0";
             [first.imagePool removeObjectForKey:[NSNumber numberWithLong:first.myid]];
             [first.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"로그아웃 하였습니다!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
             [alert show];
             //->logoutPerformThread & pop
         }
         else
         {
             self.navigationItem.rightBarButtonItem.enabled = YES;
             self.navigationItem.backBarButtonItem.enabled = YES;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"잠시 후에 다시 시도해 주세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
             [alert show];
         }
    }];
}
-(void)logoutPerformThread
{
    /*
    isKakaoLogin = NO;
    //init
    [imagePool removeAllObjects];
    [downloaderQueue cancelAllOperations];
    updateddate = nil;
    isTalk = NO;
    talk_nickname = nil;
    talk_proimg = nil;
    isStory = NO;
    story_nickname = nil;
    story_birth = nil;
    story_birthtype = 0;
    story_proimg = nil;
    story_bgimg = nil;
    isStoryPost = NO;
    story_content = nil;
    story_date = nil;
    [story_mediaimgs removeAllObjects];
    [info_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; //table refresh
    */
    //kakao_login 필드값을 0으로 설정!
    NSString *temp = [NSString stringWithFormat:URL6, myid];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    /*
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result && [[result objectForKey:@"result"] isEqualToString:@"1"])
    {
    }
    else
    {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"잠시 후에 다시 시도해 주세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
    [alert show];
    }
    */
}

//alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"로그아웃 하시겠습니까?"])
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self performSelectorOnMainThread:@selector(logoutPerform) withObject:nil waitUntilDone:YES];
        }
    }
    else if([alertView.title isEqualToString:@"로그아웃 하였습니다!"])
    {
        [NSThread detachNewThreadSelector:@selector(logoutPerformThread) toTarget:self withObject:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}












//image download queue
-(void)didFinishedDownload:(UIImage *)image at:(NSIndexPath *)indexPath forKey:(NSNumber *)num
{
    if(image)
    {
        [imagePool setObject:image forKey:num];
        [self performSelectorOnMainThread:@selector(reloadCellImage:) withObject:indexPath waitUntilDone:NO];
    }
}
-(void)reloadCellImage:(NSIndexPath *)indexPath
{
    [info_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}














- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

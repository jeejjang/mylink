//
//  SecondViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 11. 4..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SecondViewController.h"
#import "SearchCell1.h"
#import "UserViewController.h"
#import "Visual1_ViewController.h"
#import "Visual2_ViewController.h"
#import "BlindCell.h"

#define LINKSORTS @"Documents/mylink_sorts.plist"
#define LINKDATES @"Documents/mylink_dates.plist"
#define LINKNAMES @"Documents/mylink_names.plist"
#define LINKPHONES @"Documents/mylink_phones.plist"
#define LINKIDS @"Documents/mylink_ids.plist"
#define LINKRESULTS @"Documents/mylink_results.plist"
#define LINKCLICKS @"Documents/mylink_clicks.plist"
#define LINKIMGS @"Documents/mylink_imgs.plist"
#define LINKIMGFILE @"Documents/imgs"

#define URL1 @"http://jeejjang.cafe24.com/link/phonetoid_1.jsp?phone='%@'"
#define URL2 @"http://jeejjang.cafe24.com/link/linksearch2.jsp?s=%ld&e=%ld"
#define URL2_RE @"http://jeejjang.cafe24.com/link/linksearch2_refresh.jsp?s=%ld&e=%ld"
#define URL3 @"http://jeejjang.cafe24.com/link/linker_plus.jsp?e=%@"
#define URL4 @"http://jeejjang.cafe24.com/link/numofbadges.jsp?myid=%ld"
#define URL5 @"http://jeejjang.cafe24.com/link/noresult_del.jsp?s=%ld&e=%ld"
#define URL6 @"http://jeejjang.cafe24.com/link/idsofnoresult.jsp?myid=%ld"
#define MAXNODES 6


@interface SecondViewController ()
-(void)textFieldShouldReturnMethod;
-(void)textField1Changed:(UITextField *)textField;
-(void)longPressGestureRecognized:(id)sender;
-(UIView *)customSnapshotFromView:(UIView *)inputView;
-(void)nameSearchInFirst;
-(void)searchOneToOneThread:(NSArray *)array;
-(void)linkerUpdateThread:(NSSet *)set_linker;
-(void)noresultDelThread:(NSString *)str_e;
-(void)btnUpdateClicked:(id)sender;
-(void)btnMinusClicked:(id)sender;
-(void)btnDelClicked:(id)sender;
-(void)searchOneToOneUpdateThread;
-(UIImage *)drawResultImgs:(NSArray *)linkResult_array2 forNames:(NSArray *)linkNames_array2; //visual2의 썸네일 이미지
-(void)combinations:(NSMutableArray *)result1 arg1:(int)start arg2:(int)n arg3:(int)k arg4:(int)maxK;
@end

@implementation SecondViewController
@synthesize indicator_search, tabbar, first, isSearching, btn_search2, textField1, phone1, label1, label_remainedTime, timer, remainedTime, label_search;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    tableView_search.delegate = self;
    tableView_search.dataSource = self;
    tableView_minus.delegate = self;
    tableView_minus.dataSource = self;
    //shadow in view_search2
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 250.0f, 195.0f)];
    [view_search2.layer setMasksToBounds:NO];
    [view_search2.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view_search2.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [view_search2.layer setShadowOpacity:1.0f];
    [view_search2.layer setShadowRadius:3.5f];
    [view_search2.layer setShadowPath:shadowPath.CGPath];
    //shadow in view_minus
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 240.0f, 310.0f)];
    [view_minus2.layer setMasksToBounds:NO];
    [view_minus2.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view_minus2.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [view_minus2.layer setShadowOpacity:1.0f];
    [view_minus2.layer setShadowRadius:3.5f];
    [view_minus2.layer setShadowPath:shadowPath2.CGPath];
    //gesture
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldShouldReturnMethod)];
    tap1.numberOfTapsRequired = 1;
    [view_search1 addGestureRecognizer:tap1];
    [textField1 addTarget:self action:@selector(textField1Changed:) forControlEvents:UIControlEventEditingChanged];
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [tableView_search addGestureRecognizer:longPress];
    snapshot = nil;
    sourceIndexPath = nil;
    indexPath_pre = nil;
    //init
    img_noresult = [UIImage imageNamed:@"noresult.png"];
    imagePool = [NSMutableDictionary dictionary];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS];
    if([manager fileExistsAtPath:filePath])
    {
        //load from files
        linkSorts_array = [NSMutableArray arrayWithContentsOfFile:filePath];
        linkDates_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES]];
        linkNames_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES]];
        linkPhones_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES]];
        linkIds_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS]];
        linkResults_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS]];
        linkClicks_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS]];
        linkImgs_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS]];
        //images
        for(int i=0; i<[linkSorts_array count]; i++)
        {
            if([[linkSorts_array objectAtIndex:i] isEqualToString:@"0"])
            {
                [linkImgs_array replaceObjectAtIndex:i withObject:@"-1"];
            }
            else
            {
                NSString *str_num = [linkImgs_array objectAtIndex:i];
                NSString *filePath2 = [[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num];
                UIImage *image;
                if([manager fileExistsAtPath:filePath2])
                {
                    image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath2]];
                    //기존의 파일 제거
                    [manager removeItemAtPath:filePath2 error:nil];
                }
                else
                {
                    image = img_noresult;
                }
                NSString *str_i = [NSString stringWithFormat:@"%d",i];
                [imagePool setObject:image forKey:str_i];
                [linkImgs_array replaceObjectAtIndex:i withObject:str_i];
            }
        }
        //imagPool의 이미지를 파일에 저장
        for(int i=0; i<[linkSorts_array count]; i++)
        {
            if(![[linkSorts_array objectAtIndex:i] isEqualToString:@"0"])
            {
                NSString *str_i = [NSString stringWithFormat:@"%d",i];
                UIImage *image = [imagePool objectForKey:str_i];
                [UIImagePNGRepresentation(image) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_i] atomically:YES];
            }
        }
        [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
        imgNum = (int)[linkSorts_array count];
    }
    else
    {
        linkSorts_array = [NSMutableArray array];
        linkDates_array = [NSMutableArray array];
        linkNames_array = [NSMutableArray array];
        linkPhones_array = [NSMutableArray array];
        linkIds_array = [NSMutableArray array];
        linkResults_array = [NSMutableArray array];
        linkClicks_array = [NSMutableArray array];
        linkImgs_array = [NSMutableArray array];
        [manager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] withIntermediateDirectories:YES attributes:nil error:NULL];
        imgNum = 0;
    }
    [tableView_search reloadData];
    //save imgNum
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
    //[defaults synchronize];
    /*
    //badge
    int cnt = 0;
    for(NSString *str in linkClicks_array)
    {
        if([str isEqualToString:@"0"]) cnt++;
    }
    if(cnt>0)
    {
        [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
    }
    else
    {
        [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
        //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    */
    //init
    isSearching = NO;
    view_minus.hidden = YES;
    if(0== [linkSorts_array count]) view_search1.hidden = NO;
    else view_search1.hidden = YES;
    label_remainedTime.hidden = YES;
    timer = nil;
    pre_string = @"";
}





-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //(1)검색 횟수 refresh
    label_search.text = [NSString stringWithFormat:@"%d / %d", first.curSearchNum, first.maxSearchNum];
    if(first.curSearchNum < first.maxSearchNum)
    {
        label_remainedTime.hidden = NO;
        //남은 시간 계산
        float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
        remainedTime = 3600.0f - interval;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    }
    //(2)만약 UIPasteboard에 저장한 번호가 있으면 자동입력
    if(!isSearching)
    {
        NSString *str_now = [UIPasteboard generalPasteboard].string;
        if(str_now.length>0)
        {
            if(![pre_string isEqualToString:str_now])
            {
                pre_string = [NSString stringWithString:str_now];
                NSString *temp = [[[str_now stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
                if(0!=temp.length)
                {
                    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                    NSRange nond = [temp rangeOfCharacterFromSet:nonDigits];
                    if(0==nond.length) //only digit
                    {
                        NSUInteger temp_length = [temp length];
                        if(temp_length>=10 && temp_length<=11) //전화번호 길이가 10과 11사이일 때
                        {
                            if([[temp substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"]) //전화번호가 01로 시작할 때
                            {
                                //검색창 초기화
                                view_search1.hidden = NO;
                                btn_search2.enabled = NO;
                                phone1 = @"";
                                textField1.text = @"";
                                label1.text = @"";
                                label_search.text = [NSString stringWithFormat:@"%d / %d", first.curSearchNum, first.maxSearchNum]; //검색 횟수
                                //input data
                                [textField1 setText:temp];
                                [self textField1Changed:textField1];
                            }
                        }
                    }
                }
            }
        }
    }
    //(3)background fetch
    [self reloadData_back];
    //(4)refresh on the remote push notification
    if([UIApplication sharedApplication].applicationIconBadgeNumber>0)
    {
        [indicator_search startAnimating];
        isSearching = YES;
        [NSThread detachNewThreadSelector:@selector(searchPushesThread) toTarget:self withObject:nil];
    }
}





-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [tableView_search setContentInset:UIEdgeInsetsZero];
    [tableView_search setScrollIndicatorInsets:UIEdgeInsetsZero];
}



-(void)viewWillDisappear:(BOOL)animated
{
    //남은 시간 제거
    label_remainedTime.hidden = YES;
    remainedTime = 0.0f;
    [timer invalidate];
    timer = nil;
}





















//남은 시간 표시
-(void)updateCountdown
{
    int min = (int)(remainedTime / 60.0f);
    int sec = (int)(remainedTime - 60.0f*(float)min);
    label_remainedTime.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    remainedTime -= 1.0f;
    if(0.0 > remainedTime)
    {
        if(first.curSearchNum < first.maxSearchNum)
        {
            //남은 시간 다시 계산
            float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
            remainedTime = 3600.0f - interval;
        }
        else
        {
            //타이머 종료
            label_remainedTime.hidden = YES;
            label_remainedTime.text = @"";
            remainedTime = 0.0f;
            [timer invalidate];
            timer = nil;
        }
    }
}














//background fetch - refresh
-(void)reloadData_back
{
    //(1)refresh
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *flag = [defaults objectForKey:@"backfetch_refresh"];
    if([flag isEqualToString:@"1"])
    {
        [defaults setObject:@"0" forKey:@"backfetch_refresh"];
        [defaults synchronize];
        [linkSorts_array removeAllObjects];
        [linkDates_array removeAllObjects];
        [linkNames_array removeAllObjects];
        [linkPhones_array removeAllObjects];
        [linkIds_array removeAllObjects];
        [linkResults_array removeAllObjects];
        [linkClicks_array removeAllObjects];
        [linkImgs_array removeAllObjects];
        //imagePool = [NSMutableDictionary dictionary];
        [imagePool removeAllObjects];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS];
        if([manager fileExistsAtPath:filePath])
        {
            //load from files
            linkSorts_array = [NSMutableArray arrayWithContentsOfFile:filePath];
            linkDates_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES]];
            linkNames_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES]];
            linkPhones_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES]];
            linkIds_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS]];
            linkResults_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS]];
            linkClicks_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS]];
            linkImgs_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS]];
            //images
            for(int i=0; i<[linkSorts_array count]; i++)
            {
                if([[linkSorts_array objectAtIndex:i] isEqualToString:@"0"])
                {
                    [linkImgs_array replaceObjectAtIndex:i withObject:@"-1"];
                }
                else
                {
                    NSString *str_num = [linkImgs_array objectAtIndex:i];
                    NSString *filePath2 = [[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num];
                    UIImage *image;
                    if([manager fileExistsAtPath:filePath2])
                    {
                        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath2]];
                        //기존의 파일 제거
                        [manager removeItemAtPath:filePath2 error:nil];
                    }
                    else
                    {
                        image = img_noresult;
                    }
                    NSString *str_i = [NSString stringWithFormat:@"%d",i];
                    [imagePool setObject:image forKey:str_i];
                    [linkImgs_array replaceObjectAtIndex:i withObject:str_i];
                }
            }
            //imagPool의 이미지를 파일에 저장
            for(int i=0; i<[linkSorts_array count]; i++)
            {
                if(![[linkSorts_array objectAtIndex:i] isEqualToString:@"0"])
                {
                    NSString *str_i = [NSString stringWithFormat:@"%d",i];
                    UIImage *image = [imagePool objectForKey:str_i];
                    [UIImagePNGRepresentation(image) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_i] atomically:YES];
                }
            }
            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
            imgNum = (int)[linkSorts_array count];
        }
        else
        {
            linkSorts_array = [NSMutableArray array];
            linkDates_array = [NSMutableArray array];
            linkNames_array = [NSMutableArray array];
            linkPhones_array = [NSMutableArray array];
            linkIds_array = [NSMutableArray array];
            linkResults_array = [NSMutableArray array];
            linkClicks_array = [NSMutableArray array];
            linkImgs_array = [NSMutableArray array];
            [manager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] withIntermediateDirectories:YES attributes:nil error:NULL];
            imgNum = 0;
        }
        [tableView_search reloadData];
        view_search1.hidden = YES;
        view_minus.hidden = YES;
        //save imgNum
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
        //[defaults synchronize];
        //badge
        int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
        for(NSString *str in linkClicks_array)
        {
            if([str isEqualToString:@"0"]) cnt++;
        }
        if(cnt>0)
        {
            [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
            //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
        }
        else
        {
            [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
            //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
    //(2)Open Cell
    NSString *selectId_back = [defaults objectForKey:@"backfetch_id"];
    if(![selectId_back isEqualToString:@"0"])
    {
        [defaults setObject:@"0" forKey:@"backfetch_id"];
        [defaults synchronize];
        //해당하는 셀 찾아서 열기
        int index_id = -1;
        for(int i=0; i<[linkSorts_array count]; i++)
        {
            if([[linkSorts_array objectAtIndex:i] isEqualToString:@"1"])
            {
                NSString *temp_id = [[linkIds_array objectAtIndex:i] objectAtIndex:0];
                if([temp_id isEqualToString:selectId_back])
                {
                    index_id = i;
                    break;
                }
            }
        }
        if(index_id>-1)
        {
            //open the cell
            [linkClicks_array replaceObjectAtIndex:index_id withObject:@"1"];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            int row = (int)([linkSorts_array count]-1-index_id);
            [tableView_search reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
            }
            else
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
                //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
            Visual1_ViewController *visual1 = [self.storyboard instantiateViewControllerWithIdentifier:@"VISUAL1"];
            visual1.first = first;
            visual1.linkResult_array2 = [NSArray arrayWithArray:[linkResults_array objectAtIndex:index_id]];
            visual1.linkName = [[linkNames_array objectAtIndex:index_id] objectAtIndex:0];
            [self.navigationController pushViewController:visual1 animated:YES];
        }
    }
}





//push notification
-(void)searchPushesThread
{
    NSString *temp = [NSString stringWithFormat:URL6 ,first.myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        int check = [[result objectForKey:@"check"] intValue];
        if(check>0)
        {
            NSMutableArray *array_ids = [NSMutableArray arrayWithCapacity:check];
            NSDictionary *result2 = [result objectForKey:@"result"];
            for(NSDictionary *dic_id in result2)
            {
                [array_ids addObject:(NSString *)[dic_id objectForKey:@"id"]];
            }
            NSMutableSet *set_ids = [NSMutableSet set];
            NSMutableDictionary *dic_index = [NSMutableDictionary dictionary];
            for(int i=0; i<[linkSorts_array count]; i++)
            {
                if([[linkSorts_array objectAtIndex:i] isEqualToString:@"0"])
                {
                    NSString *str_id = [[linkIds_array objectAtIndex:i] objectAtIndex:0];
                    [set_ids addObject:[NSString stringWithString:str_id]];
                    [dic_index setObject:[NSNumber numberWithInt:i] forKey:str_id];
                }
            }
            //search in "linksearch2.jsp"
            for(NSString *str_id in array_ids)
            {
                //id가 "못찾은 결과"에 있는지 체크(없으면 noresult 테이블에서 삭제)
                if(![set_ids containsObject:str_id])
                {
                    NSString *temp1 = [NSString stringWithFormat:URL5 ,first.myid, (long)[str_id longLongValue]];
                    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                }
                else
                {
                    //(2-2)searching
                    NSString *temp1 = [NSString stringWithFormat:URL2 ,first.myid, (long)[str_id longLongValue]];
                    id result1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result1)
                    {
                        int check = [[result1 objectForKey:@"check"] intValue];
                        /*
                        if(-3==check) //(1) connection error (결과 저장 x)
                        {
                        isSearching = NO;
                        [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                        }
                        */
                        /*
                        if(check<=0) //(2) 링크결과가 없는 경우
                        {
                            [linkSorts_array addObject:@"0"];
                            [linkDates_array addObject:now];
                            NSArray *temp_array;
                            if([name isEqualToString:@""]) temp_array = [NSArray arrayWithObject:phone_2];
                            else temp_array = [NSArray arrayWithObject:name];
                            [linkNames_array addObject:temp_array];
                            [linkPhones_array addObject:[NSArray arrayWithObject:phone]];
                            [linkIds_array addObject:[NSArray arrayWithObject:inputId_str]];
                            [linkClicks_array addObject:@"1"];
                            [linkResults_array addObject:[NSArray arrayWithObjects:@"0", @"0", @"0", nil]];
                            [linkImgs_array addObject:@"-1"];
                            //refresh table
                            [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                            isSearching = NO;
                            [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                            //save in file
                            [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
                            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
                            [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
                            [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
                            [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
                            [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
                            [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
                            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
                            //검색횟수
                            first.curSearchNum--;
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                            if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                            {
                                first.searchNumSavedDate = [NSDate date];
                                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                                [defaults synchronize];
                                //타이머 작동 시작
                                [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                            }
                            else
                            {
                                [defaults synchronize];
                            }
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 찾기 실패" message:@"못찾은 링크는 나중에 자동으로 찾아서 알려줍니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                        }
                        */
                        //else //(3) 결과를 찾은 경우
                        if(check>0)
                        {
                            NSMutableSet *set_linker = [NSMutableSet set]; //for linker
                            NSDictionary *result2 = [result1 objectForKey:@"result"];
                            NSMutableArray *resultId_array2 = [NSMutableArray array];
                            NSMutableArray *resultOut_array2 = [NSMutableArray array];
                            NSMutableArray *resultIn_array2 = [NSMutableArray array];
                            for(NSDictionary *dic in result2)
                            {
                                NSMutableArray *array_CompareSets = [NSMutableArray array]; //중복을 방지하기 위한 set 배열
                                int num = [[dic objectForKey:@"num"] intValue];
                                NSDictionary *dic2 = [dic objectForKey:@"link"];
                                for(NSDictionary *dic3 in dic2)
                                {
                                    NSMutableArray *resultId_array = [NSMutableArray arrayWithCapacity:num];
                                    NSMutableArray *resultOut_array = [NSMutableArray arrayWithCapacity:num];
                                    NSMutableArray *resultIn_array = [NSMutableArray arrayWithCapacity:num];
                                    //info
                                    NSMutableSet *set_temp = [NSMutableSet setWithCapacity:num];
                                    NSDictionary *dic_info = [dic3 objectForKey:@"info"];
                                    for(NSDictionary *dic_id in dic_info)
                                    {
                                        [resultId_array addObject:(NSString *)[dic_id objectForKey:@"id"]];
                                        [set_temp addObject:(NSString *)[dic_id objectForKey:@"id"]];
                                    }
                                    //중복 check
                                    BOOL isBreak = NO;
                                    for(NSSet *set in array_CompareSets)
                                    {
                                        if([set isEqualToSet:set_temp])
                                        {
                                            isBreak = YES;
                                            break;
                                        }
                                    }
                                    if(isBreak) continue;
                                    else [array_CompareSets addObject:set_temp];
                                    [set_linker addObjectsFromArray:resultId_array];
                                    [resultId_array addObject:str_id];
                                    //out
                                    NSDictionary *dic_out = [dic3 objectForKey:@"out"];
                                    for(NSDictionary *dic_name in dic_out)
                                    {
                                        [resultOut_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                                    }
                                    //in
                                    NSDictionary *dic_in = [dic3 objectForKey:@"in"];
                                    for(NSDictionary *dic_name in dic_in)
                                    {
                                        [resultIn_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                                    }
                                    [resultId_array2 addObject:resultId_array];
                                    [resultOut_array2 addObject:resultOut_array];
                                    [resultIn_array2 addObject:resultIn_array];
                                }
                                [array_CompareSets removeAllObjects];
                            }
                            int cur_index = [[dic_index objectForKey:str_id] intValue];
                            [linkResults_array removeObjectAtIndex:cur_index];
                            [linkResults_array addObject:[NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil]];
                            [linkSorts_array removeObjectAtIndex:cur_index];
                            [linkSorts_array addObject:@"1"];
                            [linkDates_array removeObjectAtIndex:cur_index];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"yyyyMMddHHmm"];
                            NSString *now = [formatter stringFromDate:[NSDate date]];
                            [linkDates_array addObject:now];
                            NSArray *temp_array = [NSArray arrayWithArray:[linkNames_array objectAtIndex:cur_index]];
                            [linkNames_array removeObjectAtIndex:cur_index];
                            [linkNames_array addObject:temp_array];
                            NSArray *temp_array1 = [NSArray arrayWithArray:[linkPhones_array objectAtIndex:cur_index]];
                            [linkPhones_array removeObjectAtIndex:cur_index];
                            [linkPhones_array addObject:temp_array1];
                            [linkIds_array removeObjectAtIndex:cur_index];
                            [linkIds_array addObject:[NSArray arrayWithObject:str_id]];
                            [linkClicks_array removeObjectAtIndex:cur_index];
                            [linkClicks_array addObject:@"0"];
                            //draw thumbnail image
                            NSArray *linkResult_array2 = [NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil];
                            NSString *linkName = [temp_array objectAtIndex:0];
                            int numOfImgs = (int)[[linkResult_array2 objectAtIndex:0] count];
                            //NSMutableArray *img_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                            //NSMutableArray *pos_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                            //[1]Draw image
                            UIImage *arrow1 = [UIImage imageNamed:@"arrow1.png"];
                            UIImage *arrow2 = [UIImage imageNamed:@"arrow2.png"];
                            UIFont *font = [UIFont systemFontOfSize:15.0f];
                            NSMutableParagraphStyle *style_out = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            style_out.alignment = NSTextAlignmentRight;
                            NSDictionary *att_out = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_out};
                            NSMutableParagraphStyle *style_in = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            style_in.alignment = NSTextAlignmentLeft;
                            NSDictionary *att_in = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_in};
                            NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            style_title.alignment = NSTextAlignmentCenter;
                            NSDictionary *att_title = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f], NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
                            //NSMutableParagraphStyle *style_rank = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                            //style_rank.alignment = NSTextAlignmentCenter;
                            //NSDictionary *att_rank = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f], NSParagraphStyleAttributeName:style_rank, NSForegroundColorAttributeName:[UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]};
                            float width = 320.0f;
                            //for(int i=0; i<numOfImgs; i++)
                            //{
                            int i=0;
                            NSMutableArray *pos_array2 = [NSMutableArray arrayWithCapacity:([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]+1)];
                            float nodeNum = (float)([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]-1); //s와 e를 제외한 개수
                            float height = 100.0f + 120.0f + 60.0f*nodeNum + 44.0f*(nodeNum+1) + 5.0f*(2.0f*nodeNum+2.0f);
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                            //(1)s
                            [[UIColor grayColor] setStroke];
                            [[UIColor blueColor] setFill];
                            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(130.0f, 50.0f, 60.0f, 60.0f)];
                            [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:160.0f], [NSNumber numberWithFloat:80.0f], nil]];
                            [path setLineWidth:2.0f];
                            [path fill];
                            [path stroke];
                            float curX = 130.0f;
                            float curY = 110.0f;
                            [@"나" drawInRect:CGRectMake(130.0f, 25.0f, 60.0f, 20.0f) withAttributes:att_title];
                            NSArray *resultOut_array = [[linkResult_array2 objectAtIndex:1] objectAtIndex:i];
                            NSArray *resultIn_array = [[linkResult_array2 objectAtIndex:2] objectAtIndex:i];
                            //(2)arrow & node
                            for(int i=0; i<(int)nodeNum; i++)
                            {
                                //out & in
                                NSString *str_out = [resultOut_array objectAtIndex:i];
                                if(![str_out isEqualToString:@"null"])
                                {
                                    [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                                    [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                                }
                                NSString *str_in = [resultIn_array objectAtIndex:i];
                                if(![str_in isEqualToString:@"null"])
                                {
                                    [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                                    [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                                }
                                [[UIColor grayColor] setStroke];
                                [[UIColor whiteColor] setFill];
                                curY += 49.0f;
                                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                                [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                                [path setLineWidth:2.0f];
                                [path fill];
                                [path stroke];
                                curY += 65.0f;
                            }
                            //(3)last arrow
                            //out & in
                            NSString *str_out = [resultOut_array lastObject];
                            if(![str_out isEqualToString:@"null"])
                            {
                                [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                                [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                            }
                            NSString *str_in = [resultIn_array lastObject];
                            if(![str_in isEqualToString:@"null"])
                            {
                                [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                                [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                            }
                            curY += 49.0f;
                            //(4) e
                            [[UIColor grayColor] setStroke];
                            [[UIColor blueColor] setFill];
                            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                            [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                            [path setLineWidth:2.0f];
                            [path fill];
                            [path stroke];
                            [linkName drawInRect:CGRectMake(curX-40, curY+80.0f, 140.0f, 20.0f) withAttributes:att_title];
                            UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 2.0f);
                            else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 3.0f);
                            else UIGraphicsBeginImageContext(CGSizeMake(50.0f, 60.0f));
                            [resultImg drawInRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                            path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                            [path setLineWidth:2.0f];
                            [[UIColor lightGrayColor] setStroke];
                            [path stroke];
                            if(numOfImgs>1)
                            {
                                //draw number
                                NSDictionary *att_img = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:style_out, NSForegroundColorAttributeName:[UIColor redColor]};
                                [[NSString stringWithFormat:@"%d",numOfImgs] drawInRect:CGRectMake(17.0f, 39.0f, 33.0f, 21.0f) withAttributes:att_img];
                            }
                            UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            NSString *str_num = [NSString stringWithFormat:@"%d",imgNum];
                            [linkImgs_array removeObjectAtIndex:cur_index];
                            [linkImgs_array addObject:str_num];
                            [imagePool setObject:resultImg2 forKey:str_num];
                            [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
                            imgNum++;
                            //save imgNum
                            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
                            //[defaults synchronize];
                            //refresh table
                            //[tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                            //isSearching = NO;
                            //[indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                            //save in file
                            [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
                            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
                            [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
                            [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
                            [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
                            [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
                            [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
                            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
                            /*
                            //검색횟수
                            first.curSearchNum--;
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                            if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                            {
                                first.searchNumSavedDate = [NSDate date];
                                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                                [defaults synchronize];
                                //타이머 작동 시작
                                [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                            }
                            else
                            {
                                [defaults synchronize];
                            }
                            */
                            /*
                            //badge
                            //(2)tabbar
                            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
                            for(NSString *str in linkClicks_array)
                            {
                                if([str isEqualToString:@"0"]) cnt++;
                            }
                            if(cnt>0)
                            {
                                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
                            }
                            else
                            {
                                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
                            }
                            */
                            //linker
                            [NSThread detachNewThreadSelector:@selector(linkerUpdateThread:) toTarget:self withObject:set_linker];
                        }
                    }
                    /*
                    else
                    {
                        isSearching = NO;
                        [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                    }
                    */
                }
            }
        }//if(check>0)
        //refresh table
        [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        isSearching = NO;
        //badge value update
        //(1)icon
        NSString *temp_icon = [NSString stringWithFormat:URL4 ,first.myid];
        id result_icon = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp_icon]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
        int cnt_icon = 0;
        if(result_icon)
        {
            cnt_icon = [[result_icon objectForKey:@"num"] intValue];
            if(cnt_icon>0)
            {
                [UIApplication sharedApplication].applicationIconBadgeNumber = cnt_icon;
            }
            else
            {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
        }
        //(2)tabbar
        //UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
        int cnt2 = cnt_icon;
        for(NSString *str in linkClicks_array)
        {
            if([str isEqualToString:@"0"]) cnt2++;
        }
        if(cnt2>0) [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", cnt2];
        else [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
    }//if(result)
    //Open Cell
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectId_push = [defaults objectForKey:@"push_id"];
    if(![selectId_push isEqualToString:@"0"])
    {
        [defaults setObject:@"0" forKey:@"push_id"];
        [defaults synchronize];
        //해당하는 셀 찾아서 열기
        int index_id = -1;
        for(int i=0; i<[linkSorts_array count]; i++)
        {
            if([[linkSorts_array objectAtIndex:i] isEqualToString:@"1"])
            {
                NSString *temp_id = [[linkIds_array objectAtIndex:i] objectAtIndex:0];
                if([temp_id isEqualToString:selectId_push])
                {
                    index_id = i;
                    break;
                }
            }
        }
        if(index_id>-1)
        {
            //open the cell
            [linkClicks_array replaceObjectAtIndex:index_id withObject:@"1"];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            int row = (int)([linkSorts_array count]-1-index_id);
            [tableView_search reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
            }
            else
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
                //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
            Visual1_ViewController *visual1 = [self.storyboard instantiateViewControllerWithIdentifier:@"VISUAL1"];
            visual1.first = first;
            visual1.linkResult_array2 = [NSArray arrayWithArray:[linkResults_array objectAtIndex:index_id]];
            visual1.linkName = [[linkNames_array objectAtIndex:index_id] objectAtIndex:0];
            [self.navigationController pushViewController:visual1 animated:YES];
        }
    }
    [indicator_search stopAnimating];
}























//tableView_search, tableView_minus
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==tableView_search)
    {
        return [linkSorts_array count];
    }
    else
    {
        return [minus_array count];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView==tableView_search)
    {
        return [NSString stringWithFormat:@"관계결과를 서로 합치려면 해당 결과를 길게 눌러 이동시키세요(최대 %d명까지)", MAXNODES];
    }
    else
    {
        return nil;
    }
}
/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([linkSorts_array count]>=2)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 45.0f)];
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 230.0f, 40.0f)];
        [headerLabel setNumberOfLines:2];
        [headerLabel setText:@"링크결과를 서로 합치려면 해당 셀을 길게 눌러서 서로 겹치도록 이동 시키세요"];
        [headerLabel setTextAlignment:NSTextAlignmentLeft];
        [headerLabel setTextColor:[UIColor blackColor]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [headerView addSubview:headerLabel];
        return headerView;
    }
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 15.0f)];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
}
*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==tableView_search)
    {
        return 45.0f;
    }
    else
    {
        return 0.0f;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==tableView_search)
    {
        NSUInteger index = [linkSorts_array count]-1-indexPath.row; //역순
        //1.date
        NSMutableString *str_date = [NSMutableString string];
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        NSString *now = [formatter stringFromDate:date];
        NSString *temp = [linkDates_array objectAtIndex:index];
        NSString *sub1 = [temp substringWithRange:NSMakeRange(0, 4)]; //년
        NSString *sub2 = [temp substringWithRange:NSMakeRange(4, 2)]; //월
        NSString *sub3 = [temp substringWithRange:NSMakeRange(6, 2)]; //일
        NSString *sub4 = [temp substringWithRange:NSMakeRange(8, 2)]; //시
        NSString *sub5 = [temp substringWithRange:NSMakeRange(10, 2)]; //분
        //year
        if(![[now substringWithRange:NSMakeRange(0, 4)] isEqualToString:sub1]) [str_date appendFormat:@"%@년 %@월 %@일",sub1,sub2,sub3];
        else //년이 같은 경우
        {
            //month
            if([[now substringWithRange:NSMakeRange(4, 2)] isEqualToString:sub2])   //월이 같은 경우
            {
                int now_day = [[now substringWithRange:NSMakeRange(6, 2)] intValue];
                int day = [sub3 intValue];
                if(now_day == day)  //일이 같은 경우
                {
                    //시,분
                    int minute = [sub4 intValue];
                    if(minute<13) [str_date appendString:[NSString stringWithFormat:@"오전 %d:%@", minute, sub5]];
                    else [str_date appendString:[NSString stringWithFormat:@"오후 %d:%@", minute-12, sub5]];
                }
                else if(now_day == day+1) [str_date appendString:@"어제"];
                else if(now_day == day+2) [str_date appendString:@"그저께"];
                else [str_date appendString:[NSString stringWithFormat:@"%@월 %@일", sub2, sub3]];
            }
            else
            {
                [str_date appendString:[NSString stringWithFormat:@"%@월 %@일", sub2, sub3]];
            }
        }
        NSString *str_sort = [linkSorts_array objectAtIndex:index];
        if([str_sort isEqualToString:@"0"]) //(1)결과가 없는 경우
        {
            SearchCell1 *cell = [tableView_search dequeueReusableCellWithIdentifier:@"SEARCH3"];
            [cell.label_date setText:str_date];
            //2.name(phone)
            [cell.label_names setText:[[linkNames_array objectAtIndex:index] objectAtIndex:0]];
            [cell.label_names setTextColor:[UIColor blackColor]];
            //3.imageView
            [cell.imageView setImage:img_noresult];
            return cell;
        }
        else if([str_sort isEqualToString:@"1"])    //(2)결과가 있는 경우(1:1)
        {
            SearchCell1 *cell = [tableView_search dequeueReusableCellWithIdentifier:@"SEARCH1"];
            [cell.label_date setText:str_date];
            //2.name(phone)
            [cell.label_names setText:[[linkNames_array objectAtIndex:index] objectAtIndex:0]];
            if([[linkClicks_array objectAtIndex:index] isEqualToString:@"1"])
            {
                cell.view_first.hidden = YES;
            }
            else
            {
                cell.view_first.hidden = NO;
            }
            //3.imageView
            //cell.imageView_back.backgroundColor = [UIColor lightGrayColor];
            [cell.imageView setImage:[imagePool objectForKey:[linkImgs_array objectAtIndex:index]]];
            //[cell bringSubviewToFront:cell.imageView];
            //4.button
            [cell.btn_update addTarget:self action:@selector(btnUpdateClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else    //(3)결과가 있는 경우(1:n)
        {
            SearchCell1 *cell = [tableView_search dequeueReusableCellWithIdentifier:@"SEARCH2"];
            [cell.label_date setText:str_date];
            //2.name(phone)
            NSMutableString *names = [NSMutableString string];
            NSArray *array = [linkNames_array objectAtIndex:index];
            [names appendString:[NSString stringWithFormat:@"[%d] ",(int)[array count]]];
            for(int i=0; i<[array count]; i++)
            {
                [names appendString:[array objectAtIndex:i]];
                if(i==[array count]-1) break;
                [names appendString:@", "];
            }
            //[cell.label_names setText:names];
            //[cell.label_names sizeToFit];
            if(!cell.label_names2)
            {
                cell.label_names2 = [[UILabel alloc] init];
                CGRect rect = [names boundingRectWithSize:CGSizeMake(246.0f, 50.0f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil];
                float height = (rect.size.height>50.0f) ? 50.0f : rect.size.height;
                cell.label_names2.numberOfLines = 0;
                cell.label_names2.font = [UIFont systemFontOfSize:14.0f];
                cell.label_names2.frame = CGRectMake(74.0f, 12.0f, 246.0f, height);
                [cell.label_names2 setText:names];
                [cell addSubview:cell.label_names2];
                cell.str_label_names2 = [NSString stringWithString:names];
            }
            else
            {
                if(![cell.str_label_names2 isEqualToString:names])
                {
                    [cell.label_names2 removeFromSuperview];
                    cell.label_names2 = [[UILabel alloc] init];
                    CGRect rect = [names boundingRectWithSize:CGSizeMake(246.0f, 50.0f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil];
                    float height = (rect.size.height>50.0f) ? 50.0f : rect.size.height;
                    cell.label_names2.numberOfLines = 0;
                    cell.label_names2.font = [UIFont systemFontOfSize:14.0f];
                    cell.label_names2.frame = CGRectMake(74.0f, 12.0f, 246.0f, height);
                    [cell.label_names2 setText:names];
                    [cell addSubview:cell.label_names2];
                    cell.str_label_names2 = [NSString stringWithString:names];
                }
            }
            if([[linkClicks_array objectAtIndex:index] isEqualToString:@"1"])
            {
                cell.view_first.hidden = YES;
            }
            else
            {
                cell.view_first.hidden = NO;
            }
            //3.imageView
            //cell.imageView_back.backgroundColor = [UIColor lightGrayColor];
            [cell.imageView setImage:[imagePool objectForKey:[linkImgs_array objectAtIndex:index]]];
            //[cell bringSubviewToFront:cell.imageView];
            //4.button
            if([str_sort isEqualToString:@"2"]) cell.btn_minus.hidden = YES;
            else
            {
                cell.btn_minus.hidden = NO;
                [cell.btn_minus addTarget:self action:@selector(btnMinusClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
    }
    else
    {
        BlindCell *cell = [tableView_minus dequeueReusableCellWithIdentifier:@"MINUSCELL"];
        cell.label_phone.text = [minus_array objectAtIndex:indexPath.row];
        [cell.btn_del addTarget:self action:@selector(btnDelClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}


















//링크 검색
- (IBAction)searchBtnClicked:(id)sender
{
    if(isSearching)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색 중" message:@"잠시 후에 다시 시도하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //init
        view_search1.hidden = NO;
        btn_search2.enabled = NO;
        phone1 = @"";
        textField1.text = @"";
        label1.text = @"";
        //검색 횟수
        label_search.text = [NSString stringWithFormat:@"%d / %d", first.curSearchNum, first.maxSearchNum];
        if(!timer && (first.curSearchNum < first.maxSearchNum))
        {
            label_remainedTime.hidden = NO;
            //남은 시간 계산
            float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
            remainedTime = 3600.0f - interval;
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
        }
    }
}
- (IBAction)cancelBtnClicked:(id)sender
{
    view_search1.hidden = YES;
    [textField1 resignFirstResponder];
}
- (IBAction)btn1Clicked:(id)sender
{
    UserViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USER"];
    user.flag = 1;
    user.second = self;
    user.name_dic = [NSMutableDictionary dictionaryWithDictionary:first.name_dic];
    user.phone_dic = [NSMutableDictionary dictionaryWithDictionary:first.phone_dic];
    user.myLinkID_dic = [NSMutableDictionary dictionaryWithDictionary:first.myLinkID_dic];
    [self presentViewController:user animated:YES completion:nil];
}
//textField
-(void)textFieldShouldReturnMethod
{
    [textField1 resignFirstResponder];
}
-(void)textField1Changed:(UITextField *)textField
{
    phone1 = [[[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
    if(0!=phone1.length)
    {
        NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange nond = [phone1 rangeOfCharacterFromSet:nonDigits];
        if(0==nond.length) //only digit
        {
            //check if '01' & its length
            NSUInteger phone_length = [phone1 length];
            if(phone_length>=10 && phone_length<=11)
            {
                if([[phone1 substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"])
                {
                    btn_search2.enabled = YES;
                    textField1.textColor = [UIColor blackColor];
                    [NSThread detachNewThreadSelector:@selector(nameSearchInFirst) toTarget:self withObject:nil];
                }
                else //전화번호가 01로 시작하지 않을 때
                {
                    label1.text = @"";
                    btn_search2.enabled = NO;
                    textField1.textColor = [UIColor redColor];
                }
            }
            else //전화번호 길이가 10과 11사이가 아닐때
            {
                label1.text = @"";
                btn_search2.enabled = NO;
                textField1.textColor = [UIColor redColor];
            }
        }
        else //숫자가 아닌 번호가 있을때
        {
            label1.text = @"";
            btn_search2.enabled = NO;
            textField1.textColor = [UIColor redColor];
        }
    }
    else //전화번호 길이가 0일때
    {
        label1.text = @"";
        btn_search2.enabled = NO;
    }
}
-(void)nameSearchInFirst    //Thread method
{
    BOOL isExist = NO;
    for(NSString *key in [first.phone_dic allKeys])
    {
        NSArray *phones = [first.phone_dic objectForKey:key];
        for(int i=0; i<[phones count]; i++)
        {
            NSString *phone = [phones objectAtIndex:i];
            if([phone isEqualToString:phone1])
            {
                isExist = YES;
                [label1 performSelectorOnMainThread:@selector(setText:) withObject:[[first.name_dic objectForKey:key] objectAtIndex:i] waitUntilDone:NO];
                break;
            }
        }
    }
    if(!isExist) [label1 performSelectorOnMainThread:@selector(setText:) withObject:@"" waitUntilDone:NO];
}
//'검색' 버튼을 눌렀을 때
- (IBAction)searchBtnClicked2:(id)sender
{
    [textField1 performSelectorOnMainThread:@selector(resignFirstResponder) withObject:nil waitUntilDone:YES];
    if(isSearching)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색 중" message:@"잠시 후에 다시 시도하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *phone = [NSString stringWithString:phone1];
        NSString *name = [NSString stringWithString:label1.text];
        if([phone isEqualToString:first.myPhone])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"입력 오류" message:@"내 전화번호가 입력되었습니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            if(0==first.curSearchNum)
            {
                float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
                int minute = (int)((3600.0f-interval)/60.0f);
                NSString *str = [NSString stringWithFormat:@"%d분 후에 검색 가능합니다(또는 검색 리필 이용)", minute];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색 횟수 부족" message:str delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                view_search1.hidden = YES;
                [indicator_search startAnimating];
                isSearching = YES;
                [NSThread detachNewThreadSelector:@selector(searchOneToOneThread:) toTarget:self withObject:[NSArray arrayWithObjects:phone, name, nil]];
            }
        }
    }
}
-(void)searchOneToOneThread:(NSArray *)array
{
    NSString *phone = [array objectAtIndex:0];
    NSString *name = [array objectAtIndex:1];
    //phone -> phone_2
    NSString *temp1 = [phone substringToIndex:3];
    NSRange r;
    NSString *temp3;
    if(11==[phone length])
    {
        r = NSMakeRange(3, 4);
        temp3 = [phone substringFromIndex:7];
    }
    else
    {
        r = NSMakeRange(3, 3);
        temp3 = [phone substringFromIndex:6];
    }
    NSString *temp2 = [phone substringWithRange:r];
    NSString *phone_2 = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
    NSString *temp = [NSString stringWithFormat:URL1, phone];
    //date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *now = [formatter stringFromDate:date];
    //id
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *inputId_str = [result objectForKey:@"id"];
        long inputId = (long)[inputId_str longLongValue];
        if(0==inputId) //(1)만약 실패했으면
        {
            isSearching = NO;
            [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            /*
            [linkSorts_array addObject:@"0"];
            [linkDates_array addObject:now];
            NSArray *temp_array;
            if([name isEqualToString:@""]) temp_array = [NSArray arrayWithObject:phone_2];
            else temp_array = [NSArray arrayWithObject:name];
            [linkNames_array addObject:temp_array];
            [linkPhones_array addObject:[NSArray arrayWithObject:phone]];
            [linkIds_array addObject:[NSArray arrayWithObject:inputId_str]];
            [linkClicks_array addObject:@"1"];
            [linkResults_array addObject:[NSArray arrayWithObjects:@"0", @"0", @"0", nil]];
            [linkImgs_array addObject:@"-1"];
            //refresh table
            [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            isSearching = NO;
            [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            //save in file
            [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
            [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
            [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
            [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
            [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
            //검색횟수
            first.curSearchNum--;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
            if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
            {
                first.searchNumSavedDate = [NSDate date];
                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                [defaults synchronize];
                //타이머 작동 시작
                [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
            }
            else
            {
                [defaults synchronize];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 찾기 실패" message:@"못찾은 링크는 백그라운드 상태에서 자동으로 검색됩니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            */
        }
        else //(2)등록된 번호일 경우
        {
            //(2-1)검색결과에 있는지 찾기
            BOOL isReturn = NO;
            for(int i=0; i<[linkSorts_array count]; i++)
            {
                NSString *temp_str = [linkSorts_array objectAtIndex:i];
                if([temp_str isEqualToString:@"0"] || [temp_str isEqualToString:@"1"])
                {
                    NSArray *temp_array = [linkIds_array objectAtIndex:i];
                    if([inputId_str isEqualToString:[temp_array objectAtIndex:0]])
                    {
                        isReturn = YES;
                        break;
                    }
                }
            }
            if(isReturn)
            {
                isSearching = NO;
                [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"중복 오류" message:@"이미 검색결과에 있습니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                return;
            }
            //(2-2)searching
            NSString *temp1 = [NSString stringWithFormat:URL2 ,first.myid, inputId];
            id result1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result1)
            {
                int check = [[result1 objectForKey:@"check"] intValue];
                if(-3==check) //(1) connection error (결과 저장 x)
                {
                    isSearching = NO;
                    [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                }
                else if(check<=0) //(2) 링크결과가 없는 경우
                {
                    [linkSorts_array addObject:@"0"];
                    [linkDates_array addObject:now];
                    NSArray *temp_array;
                    if([name isEqualToString:@""]) temp_array = [NSArray arrayWithObject:phone_2];
                    else temp_array = [NSArray arrayWithObject:name];
                    [linkNames_array addObject:temp_array];
                    [linkPhones_array addObject:[NSArray arrayWithObject:phone]];
                    [linkIds_array addObject:[NSArray arrayWithObject:inputId_str]];
                    [linkClicks_array addObject:@"1"];
                    [linkResults_array addObject:[NSArray arrayWithObjects:@"0", @"0", @"0", nil]];
                    [linkImgs_array addObject:@"-1"];
                    //refresh table
                    [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                    isSearching = NO;
                    [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                    //save in file
                    [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
                    [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
                    [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
                    [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
                    [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
                    [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
                    [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
                    [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
                    //검색횟수
                    first.curSearchNum--;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                    if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                    {
                        first.searchNumSavedDate = [NSDate date];
                        [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                        [defaults synchronize];
                        //타이머 작동 시작
                        [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                    }
                    else
                    {
                        [defaults synchronize];
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 찾기 실패" message:@"못찾은 링크는 나중에 자동으로 찾아서 알려줍니다" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                }
                else //(3) 결과를 찾은 경우
                {
                    NSMutableSet *set_linker = [NSMutableSet set]; //for linker
                    NSDictionary *result2 = [result1 objectForKey:@"result"];
                    NSMutableArray *resultId_array2 = [NSMutableArray array];
                    NSMutableArray *resultOut_array2 = [NSMutableArray array];
                    NSMutableArray *resultIn_array2 = [NSMutableArray array];
                    for(NSDictionary *dic in result2)
                    {
                        NSMutableArray *array_CompareSets = [NSMutableArray array]; //중복을 방지하기 위한 set 배열
                        int num = [[dic objectForKey:@"num"] intValue];
                        NSDictionary *dic2 = [dic objectForKey:@"link"];
                        for(NSDictionary *dic3 in dic2)
                        {
                            NSMutableArray *resultId_array = [NSMutableArray arrayWithCapacity:num];
                            NSMutableArray *resultOut_array = [NSMutableArray arrayWithCapacity:num];
                            NSMutableArray *resultIn_array = [NSMutableArray arrayWithCapacity:num];
                            //info
                            NSMutableSet *set_temp = [NSMutableSet setWithCapacity:num];
                            NSDictionary *dic_info = [dic3 objectForKey:@"info"];
                            for(NSDictionary *dic_id in dic_info)
                            {
                                [resultId_array addObject:(NSString *)[dic_id objectForKey:@"id"]];
                                [set_temp addObject:(NSString *)[dic_id objectForKey:@"id"]];
                            }
                            //중복 check
                            BOOL isBreak = NO;
                            for(NSSet *set in array_CompareSets)
                            {
                                if([set isEqualToSet:set_temp])
                                {
                                    isBreak = YES;
                                    break;
                                }
                            }
                            if(isBreak) continue;
                            else [array_CompareSets addObject:set_temp];
                            [set_linker addObjectsFromArray:resultId_array];
                            [resultId_array addObject:inputId_str];
                            //out
                            NSDictionary *dic_out = [dic3 objectForKey:@"out"];
                            for(NSDictionary *dic_name in dic_out)
                            {
                                [resultOut_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                            }
                            //in
                            NSDictionary *dic_in = [dic3 objectForKey:@"in"];
                            for(NSDictionary *dic_name in dic_in)
                            {
                                [resultIn_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                            }
                            [resultId_array2 addObject:resultId_array];
                            [resultOut_array2 addObject:resultOut_array];
                            [resultIn_array2 addObject:resultIn_array];
                        }
                        [array_CompareSets removeAllObjects];
                    }
                    [linkResults_array addObject:[NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil]];
                    [linkSorts_array addObject:@"1"];
                    [linkDates_array addObject:now];
                    NSArray *temp_array;
                    if([name isEqualToString:@""]) temp_array = [NSArray arrayWithObject:phone_2];
                    else temp_array = [NSArray arrayWithObject:name];
                    [linkNames_array addObject:temp_array];
                    [linkPhones_array addObject:[NSArray arrayWithObject:phone]];
                    [linkIds_array addObject:[NSArray arrayWithObject:inputId_str]];
                    [linkClicks_array addObject:@"0"];
                    //draw thumbnail image
                    NSArray *linkResult_array2 = [NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil];
                    NSString *linkName = [temp_array objectAtIndex:0];
                    int numOfImgs = (int)[[linkResult_array2 objectAtIndex:0] count];
                    //NSMutableArray *img_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                    //NSMutableArray *pos_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                    //[1]Draw image
                    UIImage *arrow1 = [UIImage imageNamed:@"arrow1.png"];
                    UIImage *arrow2 = [UIImage imageNamed:@"arrow2.png"];
                    UIFont *font = [UIFont systemFontOfSize:15.0f];
                    NSMutableParagraphStyle *style_out = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style_out.alignment = NSTextAlignmentRight;
                    NSDictionary *att_out = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_out};
                    NSMutableParagraphStyle *style_in = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style_in.alignment = NSTextAlignmentLeft;
                    NSDictionary *att_in = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_in};
                    NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style_title.alignment = NSTextAlignmentCenter;
                    NSDictionary *att_title = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f], NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
                    //NSMutableParagraphStyle *style_rank = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    //style_rank.alignment = NSTextAlignmentCenter;
                    //NSDictionary *att_rank = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f], NSParagraphStyleAttributeName:style_rank, NSForegroundColorAttributeName:[UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]};
                    float width = 320.0f;
                    //for(int i=0; i<numOfImgs; i++)
                    //{
                    int i=0;
                    NSMutableArray *pos_array2 = [NSMutableArray arrayWithCapacity:([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]+1)];
                    float nodeNum = (float)([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]-1); //s와 e를 제외한 개수
                    float height = 100.0f + 120.0f + 60.0f*nodeNum + 44.0f*(nodeNum+1) + 5.0f*(2.0f*nodeNum+2.0f);
                    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                    else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                    //(1)s
                    [[UIColor grayColor] setStroke];
                    [[UIColor blueColor] setFill];
                    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(130.0f, 50.0f, 60.0f, 60.0f)];
                    [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:160.0f], [NSNumber numberWithFloat:80.0f], nil]];
                    [path setLineWidth:2.0f];
                    [path fill];
                    [path stroke];
                    float curX = 130.0f;
                    float curY = 110.0f;
                    [@"나" drawInRect:CGRectMake(130.0f, 25.0f, 60.0f, 20.0f) withAttributes:att_title];
                    NSArray *resultOut_array = [[linkResult_array2 objectAtIndex:1] objectAtIndex:i];
                    NSArray *resultIn_array = [[linkResult_array2 objectAtIndex:2] objectAtIndex:i];
                    //(2)arrow & node
                    for(int i=0; i<(int)nodeNum; i++)
                    {
                        //out & in
                        NSString *str_out = [resultOut_array objectAtIndex:i];
                        if(![str_out isEqualToString:@"null"])
                        {
                            [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                            [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                        }
                        NSString *str_in = [resultIn_array objectAtIndex:i];
                        if(![str_in isEqualToString:@"null"])
                        {
                            [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                            [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                        }
                        [[UIColor grayColor] setStroke];
                        [[UIColor whiteColor] setFill];
                        curY += 49.0f;
                        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                        [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                        [path setLineWidth:2.0f];
                        [path fill];
                        [path stroke];
                        curY += 65.0f;
                    }
                    //(3)last arrow
                    //out & in
                    NSString *str_out = [resultOut_array lastObject];
                    if(![str_out isEqualToString:@"null"])
                    {
                        [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                        [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                    }
                    NSString *str_in = [resultIn_array lastObject];
                    if(![str_in isEqualToString:@"null"])
                    {
                        [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                        [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                    }
                    curY += 49.0f;
                    //(4) e
                    [[UIColor grayColor] setStroke];
                    [[UIColor blueColor] setFill];
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                    [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                    [path setLineWidth:2.0f];
                    [path fill];
                    [path stroke];
                    [linkName drawInRect:CGRectMake(curX-40, curY+80.0f, 140.0f, 20.0f) withAttributes:att_title];
                    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 2.0f);
                    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 3.0f);
                    else UIGraphicsBeginImageContext(CGSizeMake(50.0f, 60.0f));
                    [resultImg drawInRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                    path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                    [path setLineWidth:2.0f];
                    [[UIColor lightGrayColor] setStroke];
                    [path stroke];
                    if(numOfImgs>1)
                    {
                        //draw number
                        NSDictionary *att_img = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:style_out, NSForegroundColorAttributeName:[UIColor redColor]};
                        [[NSString stringWithFormat:@"%d",numOfImgs] drawInRect:CGRectMake(17.0f, 39.0f, 33.0f, 21.0f) withAttributes:att_img];
                    }
                    UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    NSString *str_num = [NSString stringWithFormat:@"%d",imgNum];
                    [linkImgs_array addObject:str_num];
                    [imagePool setObject:resultImg2 forKey:str_num];
                    [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
                    imgNum++;
                    //save imgNum
                    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
                    //[defaults synchronize];
                    //refresh table
                    [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                    isSearching = NO;
                    [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                    //save in file
                    [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
                    [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
                    [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
                    [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
                    [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
                    [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
                    [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
                    [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
                    //검색횟수
                    first.curSearchNum--;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                    if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                    {
                        first.searchNumSavedDate = [NSDate date];
                        [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                        [defaults synchronize];
                        //타이머 작동 시작
                        [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                    }
                    else
                    {
                        [defaults synchronize];
                    }
                    //badge
                    //(2)tabbar
                    int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
                    for(NSString *str in linkClicks_array)
                    {
                        if([str isEqualToString:@"0"]) cnt++;
                    }
                    if(cnt>0)
                    {
                        [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
                    }
                    else
                    {
                        [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
                    }
                    //linker
                    [NSThread detachNewThreadSelector:@selector(linkerUpdateThread:) toTarget:self withObject:set_linker];
                }
            }
            else
            {
                isSearching = NO;
                [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
        }
    }
    else
    {
        isSearching = NO;
        [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}












//새로운 링크 검색(update)
-(void)searchOneToOneUpdateThread
{
    //index_update
    NSString *inputId_str = [[linkIds_array objectAtIndex:index_update] objectAtIndex:0];
    long inputId = (long)[inputId_str longLongValue];
    NSString *phone = [[linkPhones_array objectAtIndex:index_update] objectAtIndex:0];
    NSString *name = [[linkNames_array objectAtIndex:index_update] objectAtIndex:0];
    NSString *temp1 = [phone substringToIndex:3];
    NSRange r;
    NSString *temp3;
    if(11==[phone length])
    {
        r = NSMakeRange(3, 4);
        temp3 = [phone substringFromIndex:7];
    }
    else
    {
        r = NSMakeRange(3, 3);
        temp3 = [phone substringFromIndex:6];
    }
    NSString *temp2 = [phone substringWithRange:r];
    NSString *phone_2 = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
    //date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *now = [formatter stringFromDate:date];
    //(2-2)searching
    temp1 = [NSString stringWithFormat:URL2_RE ,first.myid, inputId];
    id result1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result1)
    {
        int check = [[result1 objectForKey:@"check"] intValue];
        if(-3==check) //(1) connection error (결과 저장 x)
        {
            isSearching = NO;
            [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
        else if(check<=0) //(2) 링크결과가 없는 경우
        {
            //검색횟수
            first.curSearchNum--;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
            if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
            {
                first.searchNumSavedDate = [NSDate date];
                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                [defaults synchronize];
                //타이머 작동 시작
                [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
            }
            else
            {
                [defaults synchronize];
            }
            isSearching = NO;
            [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"새로운 링크를 찾지 못했습니다" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
        else //(3) 새로운 결과를 찾은 경우
        {
            //(a)linkResults_array의 결과
            int lengthOfLink = (int)[[[[linkResults_array objectAtIndex:index_update] objectAtIndex:0] objectAtIndex:0] count];
            NSMutableSet *linkSet_id = [NSMutableSet set];
            NSMutableSet *linkSet_out = [NSMutableSet set];
            NSMutableSet *linkSet_in = [NSMutableSet set];
            NSArray *linkResult_id = [[linkResults_array objectAtIndex:index_update] objectAtIndex:0];
            NSArray *linkResult_out = [[linkResults_array objectAtIndex:index_update] objectAtIndex:1];
            NSArray *linkResult_in = [[linkResults_array objectAtIndex:index_update] objectAtIndex:2];
            for(NSArray *array in linkResult_id)
            {
                for(NSString *str in array)
                {
                    [linkSet_id addObject:str];
                }
            }
            for(NSArray *array in linkResult_out)
            {
                for(NSString *str in array)
                {
                    [linkSet_out addObject:str];
                }
            }
            for(NSArray *array in linkResult_in)
            {
                for(NSString *str in array)
                {
                    [linkSet_in addObject:str];
                }
            }
            //(b)현재 얻은 결과
            NSMutableSet *linkSet_id2 = [NSMutableSet set];
            [linkSet_id2 addObject:inputId_str];
            NSMutableSet *linkSet_out2 = [NSMutableSet set];
            NSMutableSet *linkSet_in2 = [NSMutableSet set];
            NSDictionary *result2 = [result1 objectForKey:@"result"];
            NSMutableArray *resultId_array2 = [NSMutableArray array];
            NSMutableArray *resultOut_array2 = [NSMutableArray array];
            NSMutableArray *resultIn_array2 = [NSMutableArray array];
            for(NSDictionary *dic in result2)
            {
                NSMutableArray *array_CompareSets = [NSMutableArray array]; //중복을 방지하기 위한 set 배열
                int num = [[dic objectForKey:@"num"] intValue];
                NSDictionary *dic2 = [dic objectForKey:@"link"];
                for(NSDictionary *dic3 in dic2)
                {
                    NSMutableArray *resultId_array = [NSMutableArray arrayWithCapacity:num];
                    NSMutableArray *resultOut_array = [NSMutableArray arrayWithCapacity:num];
                    NSMutableArray *resultIn_array = [NSMutableArray arrayWithCapacity:num];
                    //info
                    NSMutableSet *set_temp = [NSMutableSet setWithCapacity:num];
                    NSDictionary *dic_info = [dic3 objectForKey:@"info"];
                    for(NSDictionary *dic_id in dic_info)
                    {
                        NSString *str = (NSString *)[dic_id objectForKey:@"id"];
                        [resultId_array addObject:[NSString stringWithString:str]];
                        [linkSet_id2 addObject:[NSString stringWithString:str]];
                        [set_temp addObject:[NSString stringWithString:str]];
                    }
                    //중복 check
                    BOOL isBreak = NO;
                    for(NSSet *set in array_CompareSets)
                    {
                        if([set isEqualToSet:set_temp])
                        {
                            isBreak = YES;
                            break;
                        }
                    }
                    if(isBreak) continue;
                    else [array_CompareSets addObject:set_temp];
                    [resultId_array addObject:inputId_str];
                    //out
                    NSDictionary *dic_out = [dic3 objectForKey:@"out"];
                    for(NSDictionary *dic_name in dic_out)
                    {
                        [resultOut_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                        [linkSet_out2 addObject:(NSString *)[dic_name objectForKey:@"name"]];
                    }
                    //in
                    NSDictionary *dic_in = [dic3 objectForKey:@"in"];
                    for(NSDictionary *dic_name in dic_in)
                    {
                        [resultIn_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                        [linkSet_in2 addObject:(NSString *)[dic_name objectForKey:@"name"]];
                    }
                    [resultId_array2 addObject:resultId_array];
                    [resultOut_array2 addObject:resultOut_array];
                    [resultIn_array2 addObject:resultIn_array];
                }
                [array_CompareSets removeAllObjects];
            }
            //compare
            if(check==lengthOfLink && [linkSet_id isEqualToSet:linkSet_id2] && [linkSet_out isEqualToSet:linkSet_out2] && [linkSet_in isEqualToSet:linkSet_in2]) //완전 동일한 경우
            {
                //검색횟수
                first.curSearchNum--;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                {
                    first.searchNumSavedDate = [NSDate date];
                    [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                    [defaults synchronize];
                    //타이머 작동 시작
                    [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                }
                else
                {
                    [defaults synchronize];
                }
                isSearching = NO;
                [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"새로운 링크를 찾지 못했습니다" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
            else
            {
                NSArray *temp_array;
                if([name isEqualToString:@""]) temp_array = [NSArray arrayWithObject:phone_2];
                else temp_array = [NSArray arrayWithObject:name];
                //draw thumbnail image
                NSArray *linkResult_array2 = [NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil];
                NSString *linkName = [temp_array objectAtIndex:0];
                int numOfImgs = (int)[[linkResult_array2 objectAtIndex:0] count];
                //NSMutableArray *img_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                //NSMutableArray *pos_array = [NSMutableArray arrayWithCapacity:numOfImgs];
                //[1]Draw image
                UIImage *arrow1 = [UIImage imageNamed:@"arrow1.png"];
                UIImage *arrow2 = [UIImage imageNamed:@"arrow2.png"];
                UIFont *font = [UIFont systemFontOfSize:15.0f];
                NSMutableParagraphStyle *style_out = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                style_out.alignment = NSTextAlignmentRight;
                NSDictionary *att_out = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_out};
                NSMutableParagraphStyle *style_in = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                style_in.alignment = NSTextAlignmentLeft;
                NSDictionary *att_in = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_in};
                NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                style_title.alignment = NSTextAlignmentCenter;
                NSDictionary *att_title = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f], NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
                //NSMutableParagraphStyle *style_rank = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                //style_rank.alignment = NSTextAlignmentCenter;
                //NSDictionary *att_rank = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f], NSParagraphStyleAttributeName:style_rank, NSForegroundColorAttributeName:[UIColor colorWithRed:0.0f green:128.0f/255.0f blue:1.0f alpha:1.0f]};
                float width = 320.0f;
                //for(int i=0; i<numOfImgs; i++)
                //{
                int i=0;
                NSMutableArray *pos_array2 = [NSMutableArray arrayWithCapacity:([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]+1)];
                float nodeNum = (float)([[[linkResult_array2 objectAtIndex:0] objectAtIndex:i] count]-1); //s와 e를 제외한 개수
                float height = 100.0f + 120.0f + 60.0f*nodeNum + 44.0f*(nodeNum+1) + 5.0f*(2.0f*nodeNum+2.0f);
                if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 2.0f);
                else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 3.0f);
                else UIGraphicsBeginImageContext(CGSizeMake(width, height));
                //(1)s
                [[UIColor grayColor] setStroke];
                [[UIColor blueColor] setFill];
                UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(130.0f, 50.0f, 60.0f, 60.0f)];
                [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:160.0f], [NSNumber numberWithFloat:80.0f], nil]];
                [path setLineWidth:2.0f];
                [path fill];
                [path stroke];
                float curX = 130.0f;
                float curY = 110.0f;
                [@"나" drawInRect:CGRectMake(130.0f, 25.0f, 60.0f, 20.0f) withAttributes:att_title];
                NSArray *resultOut_array = [[linkResult_array2 objectAtIndex:1] objectAtIndex:i];
                NSArray *resultIn_array = [[linkResult_array2 objectAtIndex:2] objectAtIndex:i];
                //(2)arrow & node
                for(int i=0; i<(int)nodeNum; i++)
                {
                    //out & in
                    NSString *str_out = [resultOut_array objectAtIndex:i];
                    if(![str_out isEqualToString:@"null"])
                    {
                        [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                        [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                    }
                    NSString *str_in = [resultIn_array objectAtIndex:i];
                    if(![str_in isEqualToString:@"null"])
                    {
                        [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                        [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                    }
                    [[UIColor grayColor] setStroke];
                    [[UIColor whiteColor] setFill];
                    curY += 49.0f;
                    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                    [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                    [path setLineWidth:2.0f];
                    [path fill];
                    [path stroke];
                    curY += 65.0f;
                }
                //(3)last arrow
                //out & in
                NSString *str_out = [resultOut_array lastObject];
                if(![str_out isEqualToString:@"null"])
                {
                    [str_out drawInRect:CGRectMake(curX-110.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_out];
                    [arrow1 drawInRect:CGRectMake(curX+5.0f, curY+5.0f, 10.0f, 44.0f)];
                }
                NSString *str_in = [resultIn_array lastObject];
                if(![str_in isEqualToString:@"null"])
                {
                    [str_in drawInRect:CGRectMake(curX+70.0f, curY+17.0f, 100.0f, 20.0f) withAttributes:att_in];
                    [arrow2 drawInRect:CGRectMake(curX+45.0f, curY+5.0f, 10.0f, 44.0f)];
                }
                curY += 49.0f;
                //(4) e
                [[UIColor grayColor] setStroke];
                [[UIColor blueColor] setFill];
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX, curY+5.0f, 60.0f, 60.0f)];
                [pos_array2 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:curX+30.0f], [NSNumber numberWithFloat:curY+5.0f+30.0f], nil]];
                [path setLineWidth:2.0f];
                [path fill];
                [path stroke];
                [linkName drawInRect:CGRectMake(curX-40, curY+80.0f, 140.0f, 20.0f) withAttributes:att_title];
                UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 2.0f);
                else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 3.0f);
                else UIGraphicsBeginImageContext(CGSizeMake(50.0f, 60.0f));
                [resultImg drawInRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
                [path setLineWidth:2.0f];
                [[UIColor lightGrayColor] setStroke];
                [path stroke];
                if(numOfImgs>1)
                {
                    //draw number
                    NSDictionary *att_img = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:style_out, NSForegroundColorAttributeName:[UIColor redColor]};
                    [[NSString stringWithFormat:@"%d",numOfImgs] drawInRect:CGRectMake(17.0f, 39.0f, 33.0f, 21.0f) withAttributes:att_img];
                }
                UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                NSString *str_num = [NSString stringWithString:[linkImgs_array objectAtIndex:index_update]];
                [imagePool setObject:resultImg2 forKey:str_num];
                [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
                [linkResults_array replaceObjectAtIndex:index_update withObject:[NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil]];
                [linkDates_array replaceObjectAtIndex:index_update withObject:now];
                [linkNames_array replaceObjectAtIndex:index_update withObject:temp_array];
                [linkPhones_array replaceObjectAtIndex:index_update withObject:[NSArray arrayWithObject:phone]];
                [linkIds_array replaceObjectAtIndex:index_update withObject:[NSArray arrayWithObject:inputId_str]];
                [linkClicks_array replaceObjectAtIndex:index_update withObject:@"0"];
                //refresh table
                [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                isSearching = NO;
                [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
                //save in file
                [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
                [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
                [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
                [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
                [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
                [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
                [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
                [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
                //검색횟수
                first.curSearchNum--;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                if(!first.timer_search) //만약 타이머가 작동하고 있지 않으면
                {
                    first.searchNumSavedDate = [NSDate date];
                    [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                    [defaults synchronize];
                    //타이머 작동 시작
                    [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
                }
                else
                {
                    [defaults synchronize];
                }
                //badge
                int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
                for(NSString *str in linkClicks_array)
                {
                    if([str isEqualToString:@"0"]) cnt++;
                }
                if(cnt>0)
                {
                    [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
                    //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
                }
                else
                {
                    [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
                    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                }
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"새로운 링크를 찾았습니다" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                //[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                //linker
                [linkSet_id2 minusSet:linkSet_id];
                [NSThread detachNewThreadSelector:@selector(linkerUpdateThread:) toTarget:self withObject:linkSet_id2];
            }
        }
    }
    else
    {
        isSearching = NO;
        [indicator_search performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"서버상태 오류" message:@"잠시 후에 다시 검색하세요" delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}














//linker
-(void)linkerUpdateThread:(NSSet *)set_linker
{
    NSArray *array_linker = [set_linker allObjects];
    NSMutableString *str_linker = [NSMutableString string];
    [str_linker appendFormat:@"%03d", (int)[array_linker count]];
    for(NSString *str in array_linker)
    {
        [str_linker appendFormat:@"%010d", [str intValue]];
    }
    NSString *temp = [NSString stringWithFormat:URL3 ,str_linker];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}
























//Long Press
-(void)longPressGestureRecognized:(id)sender
{
    if(tableView_search.editing) return; //편집 상태에서는 작동하지 않도록 한다
    UILongPressGestureRecognizer *longPress2 = (UILongPressGestureRecognizer *)sender;
    CGPoint location = [longPress2 locationInView:tableView_search];
    NSIndexPath *indexPath = [tableView_search indexPathForRowAtPoint:location];
    UIGestureRecognizerState state = longPress2.state;
    //auto scrolling
    if(snapshot)
    {
        CGPoint loc = [longPress2 locationInView:self.view];
        if(loc.y>self.view.frame.size.height-100.0f) //down
        {
            if(location.y<tableView_search.contentSize.height-40.0f)
            {
                [tableView_search setContentOffset:CGPointMake(0.0f, tableView_search.contentOffset.y+80) animated:YES];
            }
        }
        else if(loc.y<100.0f)
        {
            if(location.y>40.0f)
            {
                [tableView_search setContentOffset:CGPointMake(0.0f, tableView_search.contentOffset.y-80) animated:YES];
            }
        }
    }
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if(indexPath)
            {
                //결과가 없는 것은 선택하지 못하도록
                NSUInteger index = [linkSorts_array count]-1-indexPath.row; //역순
                if([[linkSorts_array objectAtIndex:index] isEqualToString:@"0"])
                {
                    snapshot = nil;
                    return;
                }
                if(indexPath_pre)
                {
                    SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                    [cell setBackgroundColor:[UIColor whiteColor]];
                    indexPath_pre = nil;
                }
                sourceIndexPath = indexPath;
                SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath];
                snapshot = [self customSnapshotFromView:cell];
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0f;
                [tableView_search addSubview:snapshot];
                [UIView animateWithDuration:0.25f animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
                    snapshot.alpha = 0.98f;
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if(snapshot)
            {
                CGPoint center = snapshot.center;
                center.y = location.y;
                snapshot.center = center;
                if(indexPath_pre)
                {
                    SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                    [cell setBackgroundColor:[UIColor whiteColor]];
                    indexPath_pre = nil;
                }
                SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath];
                if(indexPath && ![indexPath isEqual:sourceIndexPath])
                {
                    indexPath_pre = indexPath;
                    NSUInteger index = [linkSorts_array count]-1-indexPath.row; //역순
                    if([[linkSorts_array objectAtIndex:index] isEqualToString:@"0"])
                    {
                        [cell setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f]];
                    }
                    else
                    {
                        NSUInteger index2 = [linkSorts_array count]-1-sourceIndexPath.row; //역순
                        NSSet *set1 = [NSSet setWithArray:[linkPhones_array objectAtIndex:index]];
                        NSSet *set2 = [NSSet setWithArray:[linkPhones_array objectAtIndex:index2]];
                        //중복된 전화번호가 겹쳐진 전체 개수 확인
                        NSMutableSet *set = [NSMutableSet set];
                        [set unionSet:set1];
                        [set unionSet:set2];
                        if([set count]>MAXNODES)
                        {
                            [cell setBackgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f]];
                        }
                        else
                        {
                            [cell setBackgroundColor:[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.3f]];
                        }
                    }
                }
            }
            break;
        }
        default:
        {
            if(snapshot && indexPath && ![indexPath isEqual:sourceIndexPath])
            {
                NSUInteger index = [linkSorts_array count]-1-indexPath.row; //역순
                if(![[linkSorts_array objectAtIndex:index] isEqualToString:@"0"])
                {
                    NSUInteger index2 = [linkSorts_array count]-1-sourceIndexPath.row; //역순
                    NSSet *set1 = [NSSet setWithArray:[linkPhones_array objectAtIndex:index]];
                    NSSet *set2 = [NSSet setWithArray:[linkPhones_array objectAtIndex:index2]];
                    //중복된 전화번호가 겹쳐진 전체 개수 확인
                    NSMutableSet *set = [NSMutableSet set];
                    [set unionSet:set1];
                    [set unionSet:set2];
                    if([set count]<=MAXNODES)
                    {
                        //clean up
                        //SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:sourceIndexPath];
                        [UIView animateWithDuration:0.25f animations:^{
                            //snapshot.center = cell.center;
                            snapshot.transform = CGAffineTransformIdentity;
                            snapshot.alpha = 0.0f;
                        } completion:^(BOOL finished) {
                            sourceIndexPath = nil;
                            if(indexPath_pre)
                            {
                                SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                                [cell setBackgroundColor:[UIColor whiteColor]];
                                indexPath_pre = nil;
                            }
                            [snapshot removeFromSuperview];
                            snapshot = nil;
                        }];
                        NSString *names1;
                        NSArray *array1 = [linkNames_array objectAtIndex:index];
                        if(1==[array1 count])
                        {
                            names1 = [NSString stringWithFormat:@"'%@'", [array1 objectAtIndex:0]];
                        }
                        else
                        {
                            names1 = [NSString stringWithFormat:@"'%@외 %d명'", [array1 objectAtIndex:0], (int)([array1 count]-1)];
                        }
                        NSString *names2;
                        NSArray *array2 = [linkNames_array objectAtIndex:index2];
                        if(1==[array2 count])
                        {
                            names2 = [NSString stringWithFormat:@"'%@'", [array2 objectAtIndex:0]];
                        }
                        else
                        {
                            names2 = [NSString stringWithFormat:@"'%@외 %d명'", [array2 objectAtIndex:0], (int)([array2 count]-1)];
                        }
                        //매개변수
                        curIndex = index;
                        sourceIndex = index2;
                        if(1==[set1 count])
                        {
                            NSString *msg = [NSString stringWithFormat:@"%@와 %@의 링크를 합쳐 새로 생성하겠습니까?",names1,names2];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 생성" message:msg delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
                            [alert show];
                        }
                        else
                        {
                            NSString *msg = [NSString stringWithFormat:@"%@를 %@의 링크에 모두 포함시키겠습니까?",names2,names1];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 합성" message:msg delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
                            [alert show];
                        }
                    }
                    else
                    {
                        //clean up
                        SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:sourceIndexPath];
                        [UIView animateWithDuration:0.25f animations:^{
                            snapshot.center = cell.center;
                            snapshot.transform = CGAffineTransformIdentity;
                            snapshot.alpha = 0.0f;
                        } completion:^(BOOL finished) {
                            sourceIndexPath = nil;
                            if(indexPath_pre)
                            {
                                SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                                [cell setBackgroundColor:[UIColor whiteColor]];
                                indexPath_pre = nil;
                            }
                            [snapshot removeFromSuperview];
                            snapshot = nil;
                        }];
                    }
                }
                else
                {
                    //clean up
                    SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:sourceIndexPath];
                    [UIView animateWithDuration:0.25f animations:^{
                        snapshot.center = cell.center;
                        snapshot.transform = CGAffineTransformIdentity;
                        snapshot.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        sourceIndexPath = nil;
                        if(indexPath_pre)
                        {
                            SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                            [cell setBackgroundColor:[UIColor whiteColor]];
                            indexPath_pre = nil;
                        }
                        [snapshot removeFromSuperview];
                        snapshot = nil;
                    }];
                }
            }
            else
            {
                //clean up
                SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:sourceIndexPath];
                [UIView animateWithDuration:0.25f animations:^{
                    snapshot.center = cell.center;
                    snapshot.transform = CGAffineTransformIdentity;
                    snapshot.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    sourceIndexPath = nil;
                    if(indexPath_pre)
                    {
                        SearchCell1 *cell = (SearchCell1 *)[tableView_search cellForRowAtIndexPath:indexPath_pre];
                        [cell setBackgroundColor:[UIColor whiteColor]];
                        indexPath_pre = nil;
                    }
                    [snapshot removeFromSuperview];
                    snapshot = nil;
                }];
            }
            break;
        }
    }
}
-(UIView *)customSnapshotFromView:(UIView *)inputView
{
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer setOpacity:0.7f];
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [inputView.layer setOpacity:1.0f];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot2 = [[UIImageView alloc] initWithImage:image];
    snapshot2.layer.masksToBounds = NO;
    snapshot2.layer.cornerRadius = 0.0f;
    snapshot2.layer.shadowOffset = CGSizeMake(-5.0f, 0.0f);
    snapshot2.layer.shadowRadius = 5.0f;
    snapshot2.layer.shadowOpacity = 0.4f;
    return snapshot2;
}




















//alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"링크 생성"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)    //확인
        {
            NSMutableArray *results_array = [NSMutableArray array];  //linkResults_array
            NSMutableArray *ids_array = [NSMutableArray array];     //linkIds_array
            NSMutableArray *names_array = [NSMutableArray array];    //linkNames_array
            NSMutableArray *phones_array = [NSMutableArray array];   //linkPhones_array
            NSUInteger index1 = curIndex;
            NSUInteger index2 = sourceIndex;
            NSString *str_phone1 = [[linkPhones_array objectAtIndex:index1] objectAtIndex:0];
            NSArray *array_phones2 = [linkPhones_array objectAtIndex:index2];
            NSSet *set2 = [NSSet setWithArray:array_phones2];
            if([set2 containsObject:str_phone1])
            {
                //target안의 source만 갱신
                if([[linkSorts_array objectAtIndex:index2] isEqualToString:@"1"])
                {
                    //나올 수 없는 경우(1:1인데 서로 같은 경우)
                    return;
                }
                else
                {
                    NSUInteger index = [array_phones2 indexOfObject:str_phone1];
                    results_array = [NSMutableArray arrayWithArray:[linkResults_array objectAtIndex:index2]];
                    [results_array replaceObjectAtIndex:index withObject:[linkResults_array objectAtIndex:index1]];
                    ids_array = [NSMutableArray arrayWithArray:[linkIds_array objectAtIndex:index2]];
                    [ids_array replaceObjectAtIndex:index withObject:[[linkIds_array objectAtIndex:index1] objectAtIndex:0]];
                    names_array = [NSMutableArray arrayWithArray:[linkNames_array objectAtIndex:index2]];
                    [names_array replaceObjectAtIndex:index withObject:[[linkNames_array objectAtIndex:index1] objectAtIndex:0]];
                    phones_array = [NSMutableArray arrayWithArray:[linkPhones_array objectAtIndex:index2]];
                    [phones_array replaceObjectAtIndex:index withObject:[[linkPhones_array objectAtIndex:index1] objectAtIndex:0]];
                }
            }
            else
            {
                //target + source
                if([[linkSorts_array objectAtIndex:index2] isEqualToString:@"1"])
                {
                    [results_array addObject:[linkResults_array objectAtIndex:index1]];
                    [results_array addObject:[linkResults_array objectAtIndex:index2]];
                    [ids_array addObject:[[linkIds_array objectAtIndex:index1] objectAtIndex:0]];
                    [ids_array addObject:[[linkIds_array objectAtIndex:index2] objectAtIndex:0]];
                    [names_array addObject:[[linkNames_array objectAtIndex:index1] objectAtIndex:0]];
                    [names_array addObject:[[linkNames_array objectAtIndex:index2] objectAtIndex:0]];
                    [phones_array addObject:[[linkPhones_array objectAtIndex:index1] objectAtIndex:0]];
                    [phones_array addObject:[[linkPhones_array objectAtIndex:index2] objectAtIndex:0]];
                }
                else
                {
                    [results_array addObject:[linkResults_array objectAtIndex:index1]];
                    for(NSArray *array in [linkResults_array objectAtIndex:index2])
                    {
                        [results_array addObject:array];
                    }
                    [ids_array addObject:[[linkIds_array objectAtIndex:index1] objectAtIndex:0]];
                    for(NSString *str in [linkIds_array objectAtIndex:index2])
                    {
                        [ids_array addObject:str];
                    }
                    [names_array addObject:[[linkNames_array objectAtIndex:index1] objectAtIndex:0]];
                    for(NSString *str in [linkNames_array objectAtIndex:index2])
                    {
                        [names_array addObject:str];
                    }
                    [phones_array addObject:[[linkPhones_array objectAtIndex:index1] objectAtIndex:0]];
                    for(NSString *str in [linkPhones_array objectAtIndex:index2])
                    {
                        [phones_array addObject:str];
                    }
                }
            }
            //result image
            UIImage *resultImg2 = [self drawResultImgs:results_array forNames:names_array];
            NSString *str_num = [NSString stringWithFormat:@"%d",imgNum];
            [linkImgs_array addObject:str_num];
            [imagePool setObject:resultImg2 forKey:str_num];
            [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
            imgNum++;
            //save imgNum
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
            //[defaults synchronize];
            //add
            [linkResults_array addObject:results_array];
            [linkIds_array addObject:ids_array];
            [linkClicks_array addObject:@"0"];
            [linkSorts_array addObject:[NSString stringWithFormat:@"%d",(int)[ids_array count]]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmm"];
            NSString *now = [formatter stringFromDate:[NSDate date]];
            [linkDates_array addObject:now];
            [linkNames_array addObject:names_array];
            [linkPhones_array addObject:phones_array];
            //refresh table
            [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            //save in file
            [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
            [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
            [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
            [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
            [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
            }
            else
            {
                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
        }
    }
    else if([alertView.title isEqualToString:@"링크 합성"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)    //확인
        {
            NSMutableArray *results_array = [NSMutableArray array];  //linkResults_array
            NSMutableArray *ids_array = [NSMutableArray array];     //linkIds_array
            NSMutableArray *names_array = [NSMutableArray array];    //linkNames_array
            NSMutableArray *phones_array = [NSMutableArray array];   //linkPhones_array
            NSUInteger index1 = curIndex;
            NSUInteger index2 = sourceIndex;
            NSArray *array_phones1 = [linkPhones_array objectAtIndex:index1];
            NSArray *array_phones2 = [linkPhones_array objectAtIndex:index2];
            NSArray *array_results1 = [linkResults_array objectAtIndex:index1];
            NSArray *array_results2 = [linkResults_array objectAtIndex:index2];
            NSArray *array_ids1 = [linkIds_array objectAtIndex:index1];
            NSArray *array_ids2 = [linkIds_array objectAtIndex:index2];
            NSArray *array_names1 = [linkNames_array objectAtIndex:index1];
            NSArray *array_names2 = [linkNames_array objectAtIndex:index2];
            if(1==[array_phones2 count]) //1->n
            {
                NSString *str2 = [array_phones2 objectAtIndex:0];
                results_array = [NSMutableArray arrayWithArray:array_results1];
                ids_array = [NSMutableArray arrayWithArray:array_ids1];
                names_array = [NSMutableArray arrayWithArray:array_names1];
                phones_array = [NSMutableArray arrayWithArray:array_phones1];
                if([array_phones1 containsObject:str2])
                {
                    NSUInteger index = [array_phones1 indexOfObject:str2];
                    [results_array replaceObjectAtIndex:index withObject:array_results2];
                    [ids_array replaceObjectAtIndex:index withObject:[array_ids2 objectAtIndex:0]];
                    [names_array replaceObjectAtIndex:index withObject:[array_names2 objectAtIndex:0]];
                    [phones_array replaceObjectAtIndex:index withObject:[array_phones2 objectAtIndex:0]];
                }
                else
                {
                    [results_array addObject:array_results2];
                    [ids_array addObject:[array_ids2 objectAtIndex:0]];
                    [names_array addObject:[array_names2 objectAtIndex:0]];
                    [phones_array addObject:[array_phones2 objectAtIndex:0]];
                }
            }
            else    //n->n
            {
                NSMutableArray *temp2 = [NSMutableArray arrayWithCapacity:[array_phones2 count]];   //source와 target의 결과가 중복된 것은 '1' / 아니면 '0'
                for(int i=0; i<[array_phones2 count]; i++)
                {
                    [temp2 addObject:@"0"];
                }
                for(int i=0; i<[array_phones1 count]; i++)
                {
                    NSString *str1 = [array_phones1 objectAtIndex:i];
                    if([array_phones2 containsObject:str1])
                    {
                        //find index in array_phones2
                        NSUInteger index = [array_phones2 indexOfObject:str1];
                        [temp2 replaceObjectAtIndex:index withObject:@"1"];
                        [results_array addObject:[array_results2 objectAtIndex:index]];
                        [ids_array addObject:[array_ids2 objectAtIndex:index]];
                        [names_array addObject:[array_names2 objectAtIndex:index]];
                        [phones_array addObject:[array_phones2 objectAtIndex:index]];
                    }
                    else
                    {
                        [results_array addObject:[array_results1 objectAtIndex:i]];
                        [ids_array addObject:[array_ids1 objectAtIndex:i]];
                        [names_array addObject:[array_names1 objectAtIndex:i]];
                        [phones_array addObject:[array_phones1 objectAtIndex:i]];
                    }
                }
                //나머지 source 붙이기
                for(int i=0; i<[temp2 count]; i++)
                {
                    if([[temp2 objectAtIndex:i] isEqualToString:@"0"])
                    {
                        [results_array addObject:[array_results2 objectAtIndex:i]];
                        [ids_array addObject:[array_ids2 objectAtIndex:i]];
                        [names_array addObject:[array_names2 objectAtIndex:i]];
                        [phones_array addObject:[array_phones2 objectAtIndex:i]];
                    }
                }
            }
            //result image
            UIImage *resultImg2 = [self drawResultImgs:results_array forNames:names_array];
            //remove image file
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:[linkImgs_array objectAtIndex:index1]];
            if([manager fileExistsAtPath:filePath]) [manager removeItemAtPath:filePath error:nil];
            NSString *str_num = [NSString stringWithFormat:@"%d",imgNum];
            [imagePool setObject:resultImg2 forKey:str_num];
            [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
            imgNum++;
            //save imgNum
            //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
            //[defaults synchronize];
            //replace
            [linkImgs_array replaceObjectAtIndex:index1 withObject:str_num];
            [linkResults_array replaceObjectAtIndex:index1 withObject:results_array];
            [linkIds_array replaceObjectAtIndex:index1 withObject:ids_array];
            [linkNames_array replaceObjectAtIndex:index1 withObject:names_array];
            [linkPhones_array replaceObjectAtIndex:index1 withObject:phones_array];
            [linkClicks_array replaceObjectAtIndex:index1 withObject:@"0"];
            [linkSorts_array replaceObjectAtIndex:index1 withObject:[NSString stringWithFormat:@"%d",(int)[ids_array count]]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmm"];
            NSString *now = [formatter stringFromDate:[NSDate date]];
            [linkDates_array replaceObjectAtIndex:index1 withObject:now];
            //refresh table
            [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            //save in file
            [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
            [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
            [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
            [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
            [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
            [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
            }
            else
            {
                [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
        }
    }
    else if([alertView.title isEqualToString:@"새로운 링크 검색"])
    {
        if(buttonIndex==alertView.firstOtherButtonIndex)
        {
            if(0==first.curSearchNum)
            {
                float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
                int minute = (int)((3600.0f-interval)/60.0f);
                NSString *str = [NSString stringWithFormat:@"%d분 후에 검색 가능합니다(또는 검색 리필 이용)", minute];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"검색 횟수 부족" message:str delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [indicator_search startAnimating];
                isSearching = YES;
                [NSThread detachNewThreadSelector:@selector(searchOneToOneUpdateThread) toTarget:self withObject:nil];
            }
        }
    }
}





















//cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = [linkSorts_array count]-1-indexPath.row;
    if([[linkSorts_array objectAtIndex:index] isEqualToString:@"0"]) return;
    else
    {
        if([[linkClicks_array objectAtIndex:index] isEqualToString:@"0"]) // 처음 선택이면
        {
            [linkClicks_array replaceObjectAtIndex:index withObject:@"1"];
            [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
            [tableView_search reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            for(NSString *str in linkClicks_array)
            {
                if([str isEqualToString:@"0"]) cnt++;
            }
            if(cnt>0)
            {
                
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
                //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
            }
            else
            {
                [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
                //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
        }
        NSString *str_sort = [linkSorts_array objectAtIndex:index];
        if([str_sort isEqualToString:@"1"])
        {
            Visual1_ViewController *visual1 = [self.storyboard instantiateViewControllerWithIdentifier:@"VISUAL1"];
            visual1.first = first;
            visual1.linkResult_array2 = [NSArray arrayWithArray:[linkResults_array objectAtIndex:index]];
            visual1.linkName = [[linkNames_array objectAtIndex:index] objectAtIndex:0];
            [self.navigationController pushViewController:visual1 animated:YES];
        }
        else
        {
            Visual2_ViewController *visual2 = [self.storyboard instantiateViewControllerWithIdentifier:@"VISUAL2"];
            visual2.first = first;
            visual2.linkResult_array2 = [NSArray arrayWithArray:[linkResults_array objectAtIndex:index]];
            visual2.linkNames_array2 = [NSArray arrayWithArray:[linkNames_array objectAtIndex:index]];
            [self.navigationController pushViewController:visual2 animated:YES];
        }
    }
}














//Edit Cell
- (IBAction)editBtnClicked:(id)sender
{
    if(!tableView_search.editing)
    {
        ((UIBarButtonItem *)sender).title = @"완료";
        [tableView_search removeGestureRecognizer:longPress];
    }
    else
    {
        ((UIBarButtonItem *)sender).title = @"편집";
        [tableView_search addGestureRecognizer:longPress];
    }
    tableView_search.editing = !tableView_search.editing;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"삭제";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [linkSorts_array count]-1-indexPath.row;
    //remove
    //image data
    if(![[linkSorts_array objectAtIndex:index] isEqualToString:@"0"])
    {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:[linkImgs_array objectAtIndex:index]];
        if([manager fileExistsAtPath:filePath]) [manager removeItemAtPath:filePath error:nil];
    }
    else
    {
        //delete from noresult table
        NSString *str_e = [[linkIds_array objectAtIndex:index] objectAtIndex:0];
        [NSThread detachNewThreadSelector:@selector(noresultDelThread:) toTarget:self withObject:str_e];
    }
    [linkSorts_array removeObjectAtIndex:index];
    [linkClicks_array removeObjectAtIndex:index];
    [linkDates_array removeObjectAtIndex:index];
    [linkNames_array removeObjectAtIndex:index];
    [linkPhones_array removeObjectAtIndex:index];
    [linkIds_array removeObjectAtIndex:index];
    [linkResults_array removeObjectAtIndex:index];
    [linkImgs_array removeObjectAtIndex:index];
    [tableView_search reloadData];
    //badge
    int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
    for(NSString *str in linkClicks_array)
    {
        if([str isEqualToString:@"0"]) cnt++;
    }
    if(cnt>0)
    {
        
        [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",cnt];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
    }
    else
    {
        [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
        //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    //save in file
    [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
    [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
    [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
    [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
    [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
    [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
    [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
    [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
}
-(void)noresultDelThread:(NSString *)str_e
{
    NSString *temp = [NSString stringWithFormat:URL5 ,first.myid, (long)[str_e longLongValue]];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}
/*
//move
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath2 toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //[tableView_search beginUpdates];
    NSUInteger source_index = [linkSorts_array count]-1-sourceIndexPath2.row;
    NSUInteger des_index = [linkSorts_array count]-1-destinationIndexPath.row;
    NSString *temp1 = [NSString stringWithString:[linkSorts_array objectAtIndex:source_index]];
    NSString *temp2 = [NSString stringWithString:[linkClicks_array objectAtIndex:source_index]];
    NSString *temp3 = [NSString stringWithString:[linkDates_array objectAtIndex:source_index]];
    NSArray *temp4 = [NSArray arrayWithArray:[linkNames_array objectAtIndex:source_index]];
    NSArray *temp5 = [NSArray arrayWithArray:[linkPhones_array objectAtIndex:source_index]];
    NSArray *temp6 = [NSArray arrayWithArray:[linkIds_array objectAtIndex:source_index]];
    NSArray *temp7 = [NSArray arrayWithArray:[linkResults_array objectAtIndex:source_index]];
    NSString *temp8 = [NSString stringWithString: [linkImgs_array objectAtIndex:source_index]];
    //remove
    [linkSorts_array removeObjectAtIndex:source_index];
    [linkClicks_array removeObjectAtIndex:source_index];
    [linkDates_array removeObjectAtIndex:source_index];
    [linkNames_array removeObjectAtIndex:source_index];
    [linkPhones_array removeObjectAtIndex:source_index];
    [linkIds_array removeObjectAtIndex:source_index];
    [linkResults_array removeObjectAtIndex:source_index];
    [linkImgs_array removeObjectAtIndex:source_index];
    //insert
    [linkSorts_array insertObject:temp1 atIndex:des_index];
    [linkClicks_array insertObject:temp2 atIndex:des_index];
    [linkDates_array insertObject:temp3 atIndex:des_index];
    [linkNames_array insertObject:temp4 atIndex:des_index];
    [linkPhones_array insertObject:temp5 atIndex:des_index];
    [linkIds_array insertObject:temp6 atIndex:des_index];
    [linkResults_array insertObject:temp7 atIndex:des_index];
    [linkImgs_array insertObject:temp8 atIndex:des_index];
    //refresh
    //[tableView_search endUpdates];
    [tableView_search reloadData];
    //save in file
    [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
    [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
    [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
    [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
    [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
    [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
    [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
    [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
}
*/

















//button event
-(void)btnUpdateClicked:(id)sender //"새로운 링크 검색"
{
    if(isSearching) return;
    else
    {
        UIButton *btn = (UIButton *)sender;
        CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_search];
        int index = (int)([linkNames_array count]-1-[tableView_search indexPathForRowAtPoint:point].row);; //역순
        NSString *str = [NSString stringWithFormat:@"%@의 링크를 새로 검색하시겠습니까?", [[linkNames_array objectAtIndex:index] objectAtIndex:0]];
        index_update = index;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"새로운 링크 검색" message:str delegate:self cancelButtonTitle:@"취 소" otherButtonTitles:@"확 인", nil];
        [alert show];
    }
}
-(void)btnMinusClicked:(id)sender //"셀 분해"
{
    if(isSearching) return;
    else
    {
        UIButton *btn = (UIButton *)sender;
        CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_search];
        int index = (int)([linkNames_array count]-1-[tableView_search indexPathForRowAtPoint:point].row);; //역순
        minusArrayIndex = index;
        minus_array = [NSMutableArray arrayWithArray:[linkNames_array objectAtIndex:index]];
        minusDelIndex_array = [NSMutableArray array];
        btn_minusApply.enabled = NO;
        view_minus.hidden = NO;
        [tableView_minus reloadData];
    }
}
//"셀 분해"
-(void)btnDelClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = [btn.superview convertPoint:btn.center toView:tableView_minus];
    NSUInteger index = [tableView_minus indexPathForRowAtPoint:point].row;
    [minus_array removeObjectAtIndex:index];
    [minusDelIndex_array addObject:[NSString stringWithFormat:@"%d", (int)index]];
    [tableView_minus reloadData];
    if(1>=[minus_array count]) btn_minusApply.enabled = NO;
    else btn_minusApply.enabled = YES;
}
- (IBAction)minusCancelClicked:(id)sender
{
    view_minus.hidden = YES;
}
- (IBAction)minusApplyClicked:(id)sender
{
    NSArray *array_phones = [linkPhones_array objectAtIndex:minusArrayIndex];
    NSArray *array_results = [linkResults_array objectAtIndex:minusArrayIndex];
    NSArray *array_ids = [linkIds_array objectAtIndex:minusArrayIndex];
    NSArray *array_names = [linkNames_array objectAtIndex:minusArrayIndex];
    NSMutableArray *temp_array = [NSMutableArray arrayWithArray:array_ids];
    for(NSString *str in minusDelIndex_array)
    {
        int index = [str intValue];
        [temp_array replaceObjectAtIndex:index withObject:@"-1"];
    }
    NSMutableArray *phones_array = [NSMutableArray array];
    NSMutableArray *results_array = [NSMutableArray array];
    NSMutableArray *ids_array = [NSMutableArray array];
    NSMutableArray *names_array = [NSMutableArray array];
    for(int i=0; i<[temp_array count]; i++)
    {
        NSString *str  = [temp_array objectAtIndex:i];
        if(![str isEqualToString:@"-1"])
        {
            [phones_array addObject:[array_phones objectAtIndex:i]];
            [results_array addObject:[array_results objectAtIndex:i]];
            [names_array addObject:[array_names objectAtIndex:i]];
            [ids_array addObject:[array_ids objectAtIndex:i]];
        }
    }
    //result image
    UIImage *resultImg2 = [self drawResultImgs:results_array forNames:names_array];
    //remove image file
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:[linkImgs_array objectAtIndex:minusArrayIndex]];
    if([manager fileExistsAtPath:filePath]) [manager removeItemAtPath:filePath error:nil];
    NSString *str_num = [NSString stringWithFormat:@"%d",imgNum];
    [imagePool setObject:resultImg2 forKey:str_num];
    [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
    imgNum++;
    //save imgNum
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:[NSNumber numberWithInt:imgNum] forKey:@"lastimgnum"];
    //[defaults synchronize];
    //replace
    [linkImgs_array replaceObjectAtIndex:minusArrayIndex withObject:str_num];
    [linkResults_array replaceObjectAtIndex:minusArrayIndex withObject:results_array];
    [linkIds_array replaceObjectAtIndex:minusArrayIndex withObject:ids_array];
    [linkNames_array replaceObjectAtIndex:minusArrayIndex withObject:names_array];
    [linkPhones_array replaceObjectAtIndex:minusArrayIndex withObject:phones_array];
    [linkClicks_array replaceObjectAtIndex:minusArrayIndex withObject:@"0"];
    [linkSorts_array replaceObjectAtIndex:minusArrayIndex withObject:[NSString stringWithFormat:@"%d",(int)[ids_array count]]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    [linkDates_array replaceObjectAtIndex:minusArrayIndex withObject:now];
    //refresh table
    [tableView_search performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    //save in file
    [linkSorts_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS] atomically:YES];
    [linkClicks_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS] atomically:YES];
    [linkDates_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES] atomically:YES];
    [linkNames_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES] atomically:YES];
    [linkPhones_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES] atomically:YES];
    [linkIds_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS] atomically:YES];
    [linkResults_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS] atomically:YES];
    [linkImgs_array writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS] atomically:YES];
    //badge
    int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
    for(NSString *str in linkClicks_array)
    {
        if([str isEqualToString:@"0"]) cnt++;
    }
    if(cnt>0)
    {
        [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:[NSString stringWithFormat:@"%d",cnt] waitUntilDone:YES];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = cnt;
    }
    else
    {
        [[[[tabbar viewControllers] objectAtIndex:1] tabBarItem] performSelectorOnMainThread:@selector(setBadgeValue:) withObject:nil waitUntilDone:YES];
        //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    [tableView_minus reloadData];
    view_minus.hidden = YES;
}















-(void)reloadCell:(NSIndexPath *)indexPath
{
    [tableView_search reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


















-(UIImage *)drawResultImgs:(NSArray *)linkResult_array2 forNames:(NSArray *)linkNames_array2;
{
    int sortNum = (int)[linkResult_array2 count]; //nC1 노드 개수:sortNum+1
    NSMutableArray *result_order;
    //result_order
    NSMutableArray *result1 = [NSMutableArray array];
    for(int i=sortNum; i>1; i--)
    {
        [self combinations:result1 arg1:1 arg2:(sortNum+1) arg3:1 arg4:i];
    }
    //re-ordering
    result_order = [NSMutableArray arrayWithCapacity:sortNum-1];
    NSUInteger cnt = [[result1 objectAtIndex:0] count];
    NSMutableArray *temp = [NSMutableArray array];
    for(int i=0; i<[result1 count]; i++)
    {
        NSArray *array = [result1 objectAtIndex:i];
        if([array count]==cnt)
        {
            [temp addObject:array];
        }
        else
        {
            [result_order addObject:[NSArray arrayWithArray:temp]];
            [temp removeAllObjects];
            cnt = [array count];
            [temp addObject:array];
        }
        if(([result1 count]-1)==i)
        {
            [result_order addObject:[NSArray arrayWithArray:temp]];
        }
    }
    //중복된 노드 id 'set' 배열
    NSMutableArray *result_nodes1;  //nCn(없으면 0개인 set)
    NSMutableArray *result_nodes2;  //nCn-1 -> nC2( (set,...),... )
    NSMutableArray *result_nodes3;  //nC1(set,...)
    NSMutableArray *ids_array = [NSMutableArray arrayWithCapacity:sortNum];   //ids_array: linkResult_array2에서 id만을 가져와서 만든 set 배열(목적id는 제외)
    for(NSArray *array in linkResult_array2)
    {
        NSMutableSet *set = [NSMutableSet set];
        NSArray *array2 = [array objectAtIndex:0];
        for(NSArray *array3 in array2)
        {
            for(int i=0; i<[array3 count]-1; i++)
            {
                [set addObject:[array3 objectAtIndex:i]];
            }
        }
        [ids_array addObject:set];
    }
    //result_nodes
    NSMutableSet *set1 = [NSMutableSet setWithSet:[ids_array objectAtIndex:0]];
    for(int i=1; i<[ids_array count]; i++)
    {
        [set1 intersectSet:[ids_array objectAtIndex:i]];
    }
    result_nodes1 = [NSMutableArray arrayWithObject:set1];
    result_nodes2 = [NSMutableArray arrayWithCapacity:sortNum-1];
    for(NSArray *array in result_order)
    {
        NSMutableArray *temp1 = [NSMutableArray arrayWithCapacity:[array count]];
        for(NSArray *array2 in array)
        {
            NSMutableSet *temp_set = [NSMutableSet setWithSet:[ids_array objectAtIndex:([[array2 objectAtIndex:0] intValue]-2)]];
            for(int i=1; i<[array2 count]; i++)
            {
                [temp_set intersectSet:[ids_array objectAtIndex:([[array2 objectAtIndex:i] intValue]-2)]];
            }
            [temp1 addObject:temp_set];
        }
        [result_nodes2 addObject:temp1];
    }
    result_nodes3 = [NSMutableArray arrayWithCapacity:sortNum+1];
    [result_nodes3 addObject:[NSSet setWithObject:[NSString stringWithFormat:@"%ld",first.myid]]];
    for(NSArray *array in linkResult_array2)
    {
        NSSet *set = [NSSet setWithObject:[[[array objectAtIndex:0] objectAtIndex:0] lastObject]];
        [result_nodes3 addObject:set];
    }
    //Draw
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    NSMutableParagraphStyle *style_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_title.alignment = NSTextAlignmentCenter;
    NSDictionary *att_title = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_title, NSForegroundColorAttributeName:[UIColor colorWithRed:25.0f/255.0f green:116.0f/255.0f blue:0.0f alpha:1.0f]};
    font = [UIFont systemFontOfSize:30.0f];
    NSMutableParagraphStyle *style_num = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style_num.alignment = NSTextAlignmentCenter;
    NSDictionary *att_num = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style_num, NSForegroundColorAttributeName:[UIColor orangeColor]};
    float width_half, height_half;
    width_half = height_half = 30.0f+(80.0f+60.0f)*sortNum+50.0f;
    UIBezierPath *path;
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 2.0f);
    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(width_half*2.0f,height_half*2.0f), NO, 3.0f);
    else UIGraphicsBeginImageContext(CGSizeMake(width_half*2.0f, height_half*2.0f));
    int numOfNodes;
    float radius;
    float angle_inter;
    float angle_offset;
    //lines
    //nC1
    numOfNodes = sortNum+1;
    NSMutableArray *pos_array3 = [NSMutableArray arrayWithCapacity:numOfNodes];
    radius = (80.0f+60.0f)*(numOfNodes-1);
    angle_offset = -M_PI/2.0f;
    angle_inter = (M_PI*2.0f)/(float)numOfNodes;
    for(int i=0; i<numOfNodes; i++)
    {
        [pos_array3 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:radius*cos(angle_offset+angle_inter*(float)i)+width_half], [NSNumber numberWithFloat:radius*sin(angle_offset+angle_inter*(float)i)+height_half], nil]];
    }
    //nCn
    NSMutableArray *pos_array1 = [NSMutableArray arrayWithCapacity:1];
    if([[result_nodes1 objectAtIndex:0] count]>0)
    {
        [pos_array1 addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:width_half], [NSNumber numberWithFloat:height_half], nil]];
        path = [UIBezierPath bezierPath];
        [[UIColor blackColor] setStroke];
        [path setLineWidth:3.0f];
        for(NSArray *array in pos_array3)
        {
            [path moveToPoint:CGPointMake(width_half, height_half)];
            [path addLineToPoint:CGPointMake([[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue])];
            [path stroke];
        }
    }
    else
    {
        [pos_array1 addObject:[NSMutableArray array]];
    }
    //nCn-1 -> nC2
    NSMutableArray *pos_array2 = [NSMutableArray arrayWithCapacity:[result_nodes2 count]];
    for(int i=0; i<[result_nodes2 count]; i++)
    {
        NSArray *array = [result_nodes2 objectAtIndex:i];
        NSArray *array2 = [result_order objectAtIndex:i];
        numOfNodes = (int)[array count];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:numOfNodes];
        radius = (80.0f+60.0f)*(float)(i+1);
        angle_offset = -M_PI/2.0f+M_PI*5.0f/36.0f*(float)(i+1);
        angle_inter = (M_PI*2.0f)/(float)numOfNodes;
        BOOL isLines = NO;
        for(int j=0; j<numOfNodes; j++)
        {
            if([[array objectAtIndex:j] count]>0)
            {
                path = [UIBezierPath bezierPath];
                [[UIColor blackColor] setStroke];
                [path setLineWidth:3.0f];
                //position
                float x = radius*cos(angle_offset+angle_inter*(float)j)+width_half;
                float y = radius*sin(angle_offset+angle_inter*(float)j)+height_half;
                [temp addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil]];
                //lines
                float x2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue];
                float y2 = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue];
                [path moveToPoint:CGPointMake(x, y)];
                [path addLineToPoint:CGPointMake(x2, y2)];
                [path stroke];
                for(NSString *str in [array2 objectAtIndex:j])
                {
                    int num = [str intValue]-1;
                    x2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:0] floatValue];
                    y2 = [[[pos_array3 objectAtIndex:num] objectAtIndex:1] floatValue];
                    [path moveToPoint:CGPointMake(x, y)];
                    [path addLineToPoint:CGPointMake(x2, y2)];
                    [path stroke];
                }
                isLines = YES;
            }
            else
            {
                [temp addObject:[NSMutableArray array]];
            }
        }
        [pos_array2 addObject:temp];
        if(isLines)
        {
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(width_half-radius, height_half-radius, radius*2.0f, radius*2.0f)];
            [[UIColor colorWithWhite:0.4f alpha:1.0f] setStroke];
            [path setLineWidth:2.0f];
            float dash[] = {4,10};
            [path setLineDash:(CGFloat *)dash count:2 phase:1];
            [path stroke];
        }
    }
    //(1)Outer circle
    radius = (80.0f+60.0f)*(float)sortNum;
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(width_half-radius, height_half-radius, radius*2.0f, radius*2.0f)];
    [[UIColor colorWithWhite:0.8f alpha:1.0f] setStroke];
    [path setLineWidth:2.0f];
    //float dash[] = {4,10};
    //[path setLineDash:(CGFloat *)dash count:2 phase:1];
    [path stroke];
    //(2)nodes
    //nC1
    [[UIColor grayColor] setStroke];
    [[UIColor blueColor] setFill];
    for(NSArray *array in pos_array3)
    {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array objectAtIndex:0] floatValue]-30.0f, [[array objectAtIndex:1] floatValue]-30.0f, 60.0f, 60.0f)];
        [path fill];
        [path setLineWidth:2.0f];
        [path stroke];
    }
    [[UIColor colorWithWhite:0.3f alpha:1.0f] setFill];
    //nCn
    if([[pos_array1 objectAtIndex:0] count]>0)
    {
        int number = (int)[[result_nodes1 objectAtIndex:0] count];
        int node_radius = 30.0f+(number-1)*2.0f;
        if(node_radius>50.0f) node_radius = 50.0f;
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue]-node_radius, [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue]-node_radius, node_radius*2.0f, node_radius*2.0f)];
        [path fill];
        [path setLineWidth:2.0f];
        [path stroke];
    }
    //nCn-1 -> nC2
    cnt = 0;
    for(NSArray *array in pos_array2)
    {
        NSArray *array_result = [result_nodes2 objectAtIndex:cnt];
        cnt++;
        [[UIColor colorWithWhite:0.3f+0.15f*(float)cnt alpha:1.0f] setFill];
        int cnt2 = 0;
        for(NSArray *array2 in array)
        {
            if([array2 count]>0)
            {
                int number = (int)[[array_result objectAtIndex:cnt2] count];
                int node_radius = 30.0f+(number-1)*2.0f;
                if(node_radius>50.0f) node_radius = 50.0f;
                path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake([[array2 objectAtIndex:0] floatValue]-node_radius, [[array2 objectAtIndex:1] floatValue]-node_radius, node_radius*2.0f, node_radius*2.0f)];
                [path fill];
                [path setLineWidth:2.0f];
                [path stroke];
            }
            cnt2++;
        }
    }
    //(3)number
    float x,y;
    if([[result_nodes1 objectAtIndex:0] count]>0)
    {
        x = [[[pos_array1 objectAtIndex:0] objectAtIndex:0] floatValue];
        y = [[[pos_array1 objectAtIndex:0] objectAtIndex:1] floatValue];
        [[NSString stringWithFormat:@"%d",(int)[[result_nodes1 objectAtIndex:0] count]] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
    }
    for(int i=0; i<[pos_array2 count]; i++)
    {
        NSArray *array = [pos_array2 objectAtIndex:i];
        NSArray *array2 = [result_nodes2 objectAtIndex:i];
        for(int j=0; j<[array2 count]; j++)
        {
            int number = (int)[[array2 objectAtIndex:j] count];
            if(0<number)
            {
                x = [[[array objectAtIndex:j] objectAtIndex:0] floatValue];
                y = [[[array objectAtIndex:j] objectAtIndex:1] floatValue];
                [[NSString stringWithFormat:@"%d",number] drawInRect:CGRectMake(x-30.0f, y-18.0f, 60.0f, 30.0f) withAttributes:att_num];
            }
        }
    }
    //(4)name
    x = [[[pos_array3 objectAtIndex:0] objectAtIndex:0] floatValue]-50.0f;
    y = [[[pos_array3 objectAtIndex:0] objectAtIndex:1] floatValue]-50.0f;
    [@"나" drawInRect:CGRectMake(x, y, 100.0f, 20.0f) withAttributes:att_title];
    for(int i=1; i<[pos_array3 count]; i++)
    {
        x = [[[pos_array3 objectAtIndex:i] objectAtIndex:0] floatValue];
        y = [[[pos_array3 objectAtIndex:i] objectAtIndex:1] floatValue];
        [[linkNames_array2 objectAtIndex:i-1] drawInRect:CGRectMake(x-50.0f, y+35.0f, 100.0f, 20.0f) withAttributes:att_title];
    }
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 2.0f);
    else if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0f) UIGraphicsBeginImageContextWithOptions(CGSizeMake(50.0f,60.0f), NO, 3.0f);
    else UIGraphicsBeginImageContext(CGSizeMake(50.0f, 60.0f));
    path = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, 50.0f, 60.0f)];
    [path setLineWidth:2.0f];
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
    [resultImg drawInRect:CGRectMake(0.0f, 5.0f, 50.0f, 50.0f)];
    UIImage *resultImg2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg2;
}
-(void)combinations:(NSMutableArray *)result1 arg1:(int)start arg2:(int)n arg3:(int)k arg4:(int)maxK
{
    int i;
    if(k>maxK && 1==v[1])
    {
        NSMutableArray *temp = [NSMutableArray array];
        for(i=2; i<=maxK; i++)
        {
            [temp addObject:[NSString stringWithFormat:@"%d", v[i]]];
        }
        [result1 addObject:temp];
        return;
    }
    for(i=start;i<=n; i++)
    {
        v[k] = i;
        [self combinations:result1 arg1:i+1 arg2:n arg3:k+1 arg4:maxK];
    }
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

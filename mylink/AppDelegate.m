//
//  AppDelegate.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 25..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

#define LINKSORTS @"Documents/mylink_sorts.plist"
#define LINKCLICKS @"Documents/mylink_clicks.plist"
#define LINKDATES @"Documents/mylink_dates.plist"
#define LINKNAMES @"Documents/mylink_names.plist"
#define LINKPHONES @"Documents/mylink_phones.plist"
#define LINKIDS @"Documents/mylink_ids.plist"
#define LINKRESULTS @"Documents/mylink_results.plist"
#define LINKIMGS @"Documents/mylink_imgs.plist"
#define LINKIMGFILE @"Documents/imgs"

#define URL2_FETCH @"http://jeejjang.cafe24.com/link/linksearch2_fetch.jsp?s=%ld&e=%ld"
#define URL3 @"http://jeejjang.cafe24.com/link/linker_plus.jsp?e=%@"
#define URL4 @"http://jeejjang.cafe24.com/link/token_update.jsp?myid=%ld&token='%@'"
#define URL5 @"http://jeejjang.cafe24.com/link/numofbadges.jsp?myid=%ld"

@interface AppDelegate ()
-(void)tokenUpdateThread:(NSString *)str;
-(void)linkerUpdateThread:(NSSet *)set_linker;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //tabbar
    [[UITabBar appearance] setTintColor:[UIColor orangeColor]];
    //Local notification 등록
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    //Remote notification 등록 -> device token
    [application registerForRemoteNotifications];
    //background fetch interval
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Local Notification
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(localNotif) //Local notification을 클릭해서 재실행 했을 때
    {
        [defaults setObject:[localNotif.userInfo objectForKey:@"backfetch_id"] forKey:@"backfetch_id"];
    }
    else //그냥 재실행 했을 때
    {
        [defaults setObject:@"0" forKey:@"backfetch_id"];
    }
    [defaults setObject:@"0" forKey:@"backfetch_refresh"];
    //Remote Notification
    NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(dictionary)
    {
        [defaults setObject:[NSString stringWithFormat:@"%@", (NSString *)[dictionary objectForKey:@"e"]] forKey:@"push_id"];
    }
    else
    {
        [defaults setObject:@"0" forKey:@"push_id"];
    }
    [defaults synchronize];
    return YES;
}







//Remote notification
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if(self.window.rootViewController.presentedViewController)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"e"]] forKey:@"push_id"];
        [defaults synchronize];
        UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
        if(1!=tabbar.selectedIndex) //if not second
        {
            tabbar.selectedIndex = 1;
        }
        if(application.applicationState==UIApplicationStateActive) //foreground에서 실행 중일 때
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"링크 검색 성공" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:@"열 기", nil];
            [alert show];
        }
    }
    completionHandler(UIBackgroundFetchResultNoData);
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:@"링크 검색 성공"])
    {
        if(buttonIndex==alertView.cancelButtonIndex) //"확 인"
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"0" forKey:@"push_id"];
            [defaults synchronize];
        }
        UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
        SecondViewController *second = (SecondViewController *)[[[[tabbar viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        if(!second.isSearching)
        {
            [second.indicator_search startAnimating];
            [NSThread detachNewThreadSelector:@selector(searchPushesThread) toTarget:second withObject:nil];
        }
    }
}





//Local notification(Local 알람을 클릭했을 때): Background fetch
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(self.window.rootViewController.presentedViewController)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[notification.userInfo objectForKey:@"backfetch_id"] forKey:@"backfetch_id"];
        [defaults synchronize];
        UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
        if(1!=tabbar.selectedIndex) //if not second
        {
            tabbar.selectedIndex = 1;
        }
    }
}











//Background <-> Forground
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if(self.window.rootViewController.presentedViewController)
    {
        //(1)검색 횟수
        FirstViewController *first = (FirstViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
        if(first.curSearchNum<first.maxSearchNum) //counting
        {
            float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
            int addValue = (int)(interval/3600.0f);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(first.curSearchNum+addValue < first.maxSearchNum)
            {
                NSDate *date2 = [NSDate dateWithTimeInterval:3600.0f*(float)addValue sinceDate:first.searchNumSavedDate];
                first.searchNumSavedDate = [NSDate dateWithTimeInterval:0.0f sinceDate:date2];
                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                first.curSearchNum += addValue;
                [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                [defaults synchronize];
                //label refresh in second, third
                SecondViewController *second = (SecondViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
                ThirdViewController *third = (ThirdViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
                [second.label_search performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d / %d", first.curSearchNum, first.maxSearchNum] waitUntilDone:YES];
                [third.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                [first performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:(3600.0f-(interval-(float)addValue*3600.0f))] waitUntilDone:YES];
                //남은 시간 표시
                second.label_remainedTime.hidden = NO;
                float interval = [[NSDate date] timeIntervalSinceDate:first.searchNumSavedDate];
                second.remainedTime = 3600.0f - interval;
                second.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:second selector:@selector(updateCountdown) userInfo:nil repeats:YES];
            }
            else
            {
                first.searchNumSavedDate = [NSDate date];
                [defaults setObject:first.searchNumSavedDate forKey:@"searchsaveddate"];
                first.curSearchNum = first.maxSearchNum;
                [defaults setObject:[NSNumber numberWithInt:first.curSearchNum] forKey:@"cursearch"];
                [defaults synchronize];
                //label refresh in second, third
                SecondViewController *second = (SecondViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
                ThirdViewController *third = (ThirdViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
                [second.label_search performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d / %d", first.curSearchNum, first.maxSearchNum] waitUntilDone:YES];
                [third.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            }
        }
        UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
        if(1==tabbar.selectedIndex) //if second
        {
            //(2)background fetch
            SecondViewController *second = (SecondViewController *)[[[[tabbar viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
            [second reloadData_back];
            //(3)Push Notification
            if([UIApplication sharedApplication].applicationIconBadgeNumber>0)
            {
                SecondViewController *second = (SecondViewController *)[[[[tabbar viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
                if(!second.isSearching)
                {
                    [second.indicator_search startAnimating];
                    [NSThread detachNewThreadSelector:@selector(searchPushesThread) toTarget:second withObject:nil];
                }
            }
        }
        else
        {
            //badge
            int cnt = (int)[UIApplication sharedApplication].applicationIconBadgeNumber;
            NSArray *linkClicks_array = [NSArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS]];
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
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //검색 횟수
    if(self.window.rootViewController.presentedViewController)
    {
        FirstViewController *first = (FirstViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
        if(first.timer_search)
        {
            [first.timer_search invalidate];
            first.timer_search = nil;
        }
        //남은 시간 제거
        SecondViewController *second = (SecondViewController *)[[[[(UITabBarController *)self.window.rootViewController.presentedViewController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        if(second.timer)
        {
            second.label_remainedTime.hidden = YES;
            second.remainedTime = 0.0f;
            [second.timer invalidate];
            second.timer = nil;
        }
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Kakao
    [KOSession handleDidBecomeActive];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}










//Background fetch
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    /*
    //for test
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    noti.alertBody = [NSString stringWithFormat:@"%@의 새로운 링크를 찾았습니다", @"010-1234-5678"];
    noti.soundName = UILocalNotificationDefaultSoundName;
    noti.userInfo = [NSDictionary dictionaryWithObject:@"3" forKey:@"backfetch_id"];
    [application presentLocalNotificationNow:noti];
    application.applicationIconBadgeNumber = 10;
    completionHandler(UIBackgroundFetchResultNoData);
    return;
    */
    
    //(1)search
    NSMutableArray *linkSorts_array;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:LINKSORTS];
    if([manager fileExistsAtPath:filePath])
    {
        //load from files
        linkSorts_array = [NSMutableArray arrayWithContentsOfFile:filePath];
        int cnt = 0;
        NSMutableArray *temp_array = [NSMutableArray array];
        for(int i=0; i<[linkSorts_array count]; i++)
        {
            NSString *str = [linkSorts_array objectAtIndex:i];
            if([str isEqualToString:@"0"])
            {
                cnt++;
                [temp_array addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
        if(cnt>0)
        {
            //check date(1시간에 최대 한개만 검색 가능)
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDate *date_check = [defaults objectForKey:@"backfetch_date"];
            if((nil==date_check) || ([[NSDate date] timeIntervalSinceDate:date_check]>3600.0f*24.0f)) //최소 24시간 마다 검색
            {
                [defaults setObject:[NSDate date] forKey:@"backfetch_date"];
                [defaults synchronize];
                //select 1 randomly
                int index_update = [[temp_array objectAtIndex:arc4random_uniform(cnt)] intValue];
                NSMutableArray *linkNames_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKNAMES]];
                NSMutableArray *linkPhones_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKPHONES]];
                NSMutableArray *linkIds_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIDS]];
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
                long myid;
                defaults = [NSUserDefaults standardUserDefaults];
                myid = (long)[[defaults objectForKey:@"mylinkid"] longLongValue];
                temp1 = [NSString stringWithFormat:URL2_FETCH ,myid, inputId];
                id result1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp1]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result1)
                {
                    int check = [[result1 objectForKey:@"check"] intValue];
                    if(check>0) //새로운 결과를 찾은 경우
                    {
                        NSMutableSet *set_linker = [NSMutableSet set]; //for linker
                        NSMutableArray *linkResults_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKRESULTS]];
                        //(b)현재 얻은 결과
                        //NSMutableSet *linkSet_id2 = [NSMutableSet set];
                        //[linkSet_id2 addObject:inputId_str];
                        //NSMutableSet *linkSet_out2 = [NSMutableSet set];
                        //NSMutableSet *linkSet_in2 = [NSMutableSet set];
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
                                    //[linkSet_id2 addObject:(NSString *)[dic_id objectForKey:@"id"]];
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
                                    //[linkSet_out2 addObject:(NSString *)[dic_name objectForKey:@"name"]];
                                }
                                //in
                                NSDictionary *dic_in = [dic3 objectForKey:@"in"];
                                for(NSDictionary *dic_name in dic_in)
                                {
                                    [resultIn_array addObject:(NSString *)[dic_name objectForKey:@"name"]];
                                    //[linkSet_in2 addObject:(NSString *)[dic_name objectForKey:@"name"]];
                                }
                                [resultId_array2 addObject:resultId_array];
                                [resultOut_array2 addObject:resultOut_array];
                                [resultIn_array2 addObject:resultIn_array];
                            }
                            [array_CompareSets removeAllObjects];
                        }
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
                        //imgNum
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        int num = [[defaults objectForKey:@"lastimgnum"] intValue];
                        NSString *str_num = [NSString stringWithFormat:@"%d", num];
                        [defaults setObject:[NSNumber numberWithInt:(num+1)] forKey:@"lastimgnum"];
                        [defaults synchronize];
                        NSMutableArray *linkImgs_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGS]];
                        //NSString *str_num = [NSString stringWithString:[linkImgs_array objectAtIndex:index_update]];
                        //[imagePool setObject:resultImg2 forKey:str_num];
                        [UIImagePNGRepresentation(resultImg2) writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:LINKIMGFILE] stringByAppendingPathComponent:str_num] atomically:YES];
                        [linkImgs_array removeObjectAtIndex:index_update];
                        [linkImgs_array addObject:str_num];
                        [linkResults_array removeObjectAtIndex:index_update];
                        [linkResults_array addObject:[NSArray arrayWithObjects:resultId_array2, resultOut_array2, resultIn_array2, nil]];
                        NSMutableArray *linkDates_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKDATES]];
                        [linkDates_array removeObjectAtIndex:index_update];
                        [linkDates_array addObject:now];
                        [linkNames_array removeObjectAtIndex:index_update];
                        [linkNames_array addObject:temp_array];
                        [linkPhones_array removeObjectAtIndex:index_update];
                        [linkPhones_array addObject:[NSArray arrayWithObject:phone]];
                        [linkIds_array removeObjectAtIndex:index_update];
                        [linkIds_array addObject:[NSArray arrayWithObject:inputId_str]];
                        NSMutableArray *linkClicks_array = [NSMutableArray arrayWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:LINKCLICKS]];
                        [linkClicks_array removeObjectAtIndex:index_update];
                        [linkClicks_array addObject:@"0"];
                        [linkSorts_array removeObjectAtIndex:index_update];
                        [linkSorts_array addObject:@"1"];
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
                        //badge
                        //(1)icon
                        NSString *temp_icon = [NSString stringWithFormat:URL5 ,myid];
                        id result_icon = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp_icon]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                        int cnt_icon=0;
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
                        UITabBarController *tabbar = (UITabBarController *)self.window.rootViewController.presentedViewController;
                        if(tabbar)
                        {
                            int cnt2 = cnt_icon;
                            for(NSString *str in linkClicks_array)
                            {
                                if([str isEqualToString:@"0"]) cnt2++;
                            }
                            if(cnt2>0) [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", cnt2];
                            else [[[tabbar viewControllers] objectAtIndex:1] tabBarItem].badgeValue = nil;
                        }
                        [defaults setObject:@"1" forKey:@"backfetch_refresh"];
                        [defaults synchronize];
                        //local notification
                        UILocalNotification *noti = [[UILocalNotification alloc] init];
                        NSMutableString *str_alert = [NSMutableString string];
                        if(numOfImgs>1) [str_alert appendString:@"["];
                        [str_alert appendString:@"나의 "];
                        for(int i=0; i<[resultOut_array count]; i++)
                        {
                            NSString *str = [resultOut_array objectAtIndex:i];
                            if([str isEqualToString:@"null"]) [str_alert appendString:@"'..'"];
                            else [str_alert appendString:[NSString stringWithFormat:@"'%@'", str]];
                            if(i==(int)([resultOut_array count]-1)) break;
                            else [str_alert appendString:@"의 "];
                        }
                        if(numOfImgs>1) [str_alert appendString:[NSString stringWithFormat:@"] 외 %d개", numOfImgs-1]];
                        noti.alertBody = [NSString stringWithFormat:@"%@ 의 새로운 링크를 찾았습니다 : %@", name, str_alert];
                        noti.soundName = UILocalNotificationDefaultSoundName;
                        noti.userInfo = [NSDictionary dictionaryWithObject:inputId_str forKey:@"backfetch_id"];
                        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
                        //linker
                        [NSThread detachNewThreadSelector:@selector(linkerUpdateThread:) toTarget:self withObject:set_linker];
                        completionHandler(UIBackgroundFetchResultNewData);
                        
                    }//if(check>0)
                    else completionHandler(UIBackgroundFetchResultNoData);
                }
                else completionHandler(UIBackgroundFetchResultNoData);
            }
            else completionHandler(UIBackgroundFetchResultNoData);
        }//if(cnt>0)
        else completionHandler(UIBackgroundFetchResultNoData);
    }
    else completionHandler(UIBackgroundFetchResultNoData);
}

-(void)linkerUpdateThread:(NSSet *)set_linker //linker
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











//etc
//device token
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //NSLog(@"%@", deviceToken);
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    [NSThread detachNewThreadSelector:@selector(tokenUpdateThread:) toTarget:self withObject:deviceId];
}
-(void)tokenUpdateThread:(NSString *)str
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    long myid = (long)[[defaults objectForKey:@"mylinkid"] longLongValue];
    NSString *temp = [NSString stringWithFormat:URL4, myid, str];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}

//Kakao
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [KOSession handleOpenURL:url];
}








@end

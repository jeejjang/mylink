//
//  FirstViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 29..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "FirstViewController.h"
#import "CustomCell_1.h"
#import "UserInfo_ViewController.h"
#import "MyLinkAddressBook.h"
#import "HiddenViewController.h"

#define MAXSEARCHNUM 3
#define CELL_HEIGHT 54.0f //self.tableView cell's height

#define HANGUL_START_CODE 0xAC00
#define HANGUL_END_CODE 0xD7A3
#define ENG_START_CODE1 0x0041
#define ENG_END_CODE1 0x005A
#define ENG_START_CODE2 0x0061
#define ENG_END_CODE2 0x007A

#define ADDRESSBOOK @"Documents/mylink_address.plist"
#define URL1 @"http://jeejjang.cafe24.com/link/address_add.jsp?myid=%ld&phone='%@'&name='%@'"
#define URL2 @"http://jeejjang.cafe24.com/link/address_update1.jsp?myid=%ld&id=%ld&name='%@'"
#define URL3 @"http://jeejjang.cafe24.com/link/address_del.jsp?myid=%ld&id=%ld"
#define URL4 @"http://jeejjang.cafe24.com/link/kakao_check.jsp?id=%ld"
#define URL5 @"http://jeejjang.cafe24.com/link/kakao_check2.jsp?id=%ld"
#define URL6 @"http://jeejjang.cafe24.com/link/kakao_logout.jsp?id=%ld"
#define URL7 @"http://jeejjang.cafe24.com/link/rank_update.jsp?myid=%ld"
#define URL8 @"http://jeejjang.cafe24.com/link/node_info.jsp?myid=%ld"
#define URL9 @"http://jeejjang.cafe24.com/link/kakao_img_thumb.jsp?id=%@"
#define URL10 @"http://jeejjang.cafe24.com/link/kakao_update1.jsp?id=%ld&up_date='%@'&t_nick='%@'&t_proimg='%@'&t_thumb='%@'"
#define URL20 @"http://jeejjang.cafe24.com/link/kakao_update2_1.jsp?id=%ld&up_date='%@'&s_nick='%@'&s_birth='%@'&s_birthtype=%d&s_proimg='%@'&s_thumb='%@'&s_bgimg='%@'&s_url='%@'"
#define URL30 @"http://jeejjang.cafe24.com/link/kakao_update3.jsp?id=%ld&up_date='%@'&s_content='%@'&s_mediaimgs='%@'&s_date='%@'"

@interface FirstViewController ()
-(void)main1;
-(void)addressBookUpdated_sub;
-(void)addressBookUpdated_sub2;
-(void)newAddressUpdate;
-(void)kakaoLoginAllUpdate;
-(void)updateMyKakaoInfo;
-(NSString *)stringByReplacingforJSON:(NSString *)str;
-(void)getNodeThread;
-(void)rankUpdateThread;
-(void)reloadCellImage:(NSIndexPath *)indexPath;
//-(void)reloadCellImage2; //reload 0 section
-(void)dismissAlertMain;
-(void)performProgress:(NSNumber *)cnt;
-(void)hiddenBtnClicked_thread:(NSString *)myLinkID;
-(void)relationNameUpload:(NSDictionary *)dic;
-(void)relationNameUpload2:(NSDictionary *)dic;
@end

@implementation FirstViewController
@synthesize tabbar, myid, myPhone, rank, node, maxSearchNum, curSearchNum, searchNumSavedDate, timer_search, second, third, isFirst, isKakaoLogin, kakao_myUpdateDate, myKakaoUrl, isThumbUpdate, imagePool, name_dic, phone_dic, myLinkID_dic, relationName_dic, kakao_dic, date_new, name_new, phone_new, relationName_new, myLinkID_new, kakao_new, name_hidden, phone_hidden, myLinkID_hidden;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    //init
    phone_dic = [NSMutableDictionary dictionary];
    name_dic = [NSMutableDictionary dictionary];
    relationName_dic = [NSMutableDictionary dictionary];
    myLinkID_dic = [NSMutableDictionary dictionary];
    kakao_dic = [NSMutableDictionary dictionary];
    date_new = [NSMutableArray array];
    name_new = [NSMutableArray array];
    phone_new = [NSMutableArray array];
    relationName_new = [NSMutableArray array];
    myLinkID_new = [NSMutableArray array];
    kakao_new = [NSMutableArray array];
    phone_hidden = [NSMutableArray array];
    name_hidden = [NSMutableArray array];
    myLinkID_hidden = [NSMutableArray array];
    //thumbnail image
    imagePool = [NSMutableDictionary dictionary];
    downloaderQueue = [[NSOperationQueue alloc] init];
    empty_img = [UIImage imageNamed:@"empty2"];
    sectionTitles = [NSArray array];
    sectionIndexTitles = [NSMutableArray array];
    searchResultDic_key = [NSMutableDictionary dictionary];
    searchResultDic_num = [NSMutableDictionary dictionary];
    searchResults_keys = [NSMutableArray array];
    addressBookRef = NULL;
    isAddressUpdating = NO;
    //isSearching = NO;
    kakao_loginDate = nil;
    kakao_myUpdateDate = @"";
    myKakaoUrl = @"0";
    isThumbUpdate = NO;
    rank = -1;
    node = -1;
    maxSearchNum = 0;
    curSearchNum = 0;
    searchNumSavedDate = nil;
    timer_search = nil;
    //keyboard notification
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //alertView(init)
    alert_main = [[UIAlertView alloc] initWithTitle:@"주소록 동기화 중입니다" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.backgroundColor = [UIColor darkGrayColor];
    [alert_main setValue:progress forKey:@"accessoryView"];
    //searchBar(init)
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.tableView.tableHeaderView = searchController.searchBar;
    searchController.searchResultsUpdater = self;
    searchController.searchBar.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [searchController.searchBar sizeToFit];
    searchController.searchBar.placeholder = @"이름, 전화번호, 관계이름 검색";
    searchController.searchBar.returnKeyType =UIReturnKeyDone;
    id barButtonAppearanceInSearchBar = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [barButtonAppearanceInSearchBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17]} forState:UIControlStateNormal];
    [barButtonAppearanceInSearchBar setTitle:@"취 소"];
    
    
    //(1)AddressBook Permission Check
    if(ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusAuthorized)
    {
        //isAccessAddress = YES;
        addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
        //update 등록
        ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookUpdated, (__bridge void *)(self));
        progress.progress = 0.0f;
        [NSThread detachNewThreadSelector:@selector(main1) toTarget:self withObject:NULL];
    }
    else
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error){
            if(granted)
            {
                //isAccessAddress = YES;
                addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
                //update 등록
                ABAddressBookRegisterExternalChangeCallback(addressBookRef, addressBookUpdated, (__bridge void *)(self));
                progress.progress = 0.0f;
                [NSThread detachNewThreadSelector:@selector(main1) toTarget:self withObject:NULL];
            }
            else
            {
                //isAccessAddress = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"'설정' - '개인 정보 보호' - '연락처'\n에서 접근 승인을 해주세요!" message:nil delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil];
                    [alert show];
                });
            }
        });
    }
    //(2)Kakao 앱연결 확인
    isKakaoLogin = NO;
    [KOSessionTask signupTaskWithProperties:nil completionHandler:^(BOOL success, NSError *error)
    {
         if (success)
         {
             //success
             isKakaoLogin = YES;
             NSDate *date = [NSDate date];
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"yyyyMMdd"];
             kakao_myUpdateDate = [NSString stringWithString:[formatter stringFromDate:date]];
             [self updateMyKakaoInfo];
             [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             
         }
         else
         {
             //failed
             if( error.code == KOServerErrorAlreadySignedUpUser)
             {
                 // do something for already registered user.
                 isKakaoLogin = YES;
                 NSDate *date = [NSDate date];
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 [formatter setDateFormat:@"yyyyMMdd"];
                 kakao_myUpdateDate = [NSString stringWithString:[formatter stringFromDate:date]];
                 [self updateMyKakaoInfo];
                 [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             }
             else
             {
                 [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                 //kakao_login 필드값을 0으로 설정!
                 NSString *temp = [NSString stringWithFormat:URL6, myid];
                 [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
             }
         }
    }];
}









-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    //(1)나의 썸네일 이미지 업데이트
    //(1-1)매번
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
    //(1-2)로그인 업데이트가 있을 때
    if(isThumbUpdate)
    {
        isThumbUpdate = NO;
        NSString *temp = [NSString stringWithFormat:URL9, [NSString stringWithFormat:@"%ld",myid]];
        id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
        if(result)
        {
            myKakaoUrl = [NSString stringWithString:[result objectForKey:@"url"]];
            [imagePool removeObjectForKey:[NSNumber numberWithLong:myid]];
        }
        else myKakaoUrl = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    //(2)'새로운 지인 추가' update: 날짜가 바뀔때 마다
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *nowDate = [formatter stringFromDate:[NSDate date]];
    for(NSString *str_date in date_new)
    {
        if(![str_date isEqualToString:nowDate])
        {
            [NSThread detachNewThreadSelector:@selector(newAddressUpdate) toTarget:self withObject:nil];
            break;
        }
    }
    //(3)kakao login check update(thumbnail image): 시간이 바뀔때 마다
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSString *nowDate2 = [formatter stringFromDate:[NSDate date]];
    if(kakao_loginDate)
    {
        if(![nowDate2 isEqualToString:kakao_loginDate])
        {
            kakao_loginDate = [NSString stringWithString:nowDate2];
            [NSThread detachNewThreadSelector:@selector(kakaoLoginAllUpdate) toTarget:self withObject:nil];
        }
    }
    //(4)my kakao info update: 날짜가 바뀔때 마다
    if(![nowDate isEqualToString:kakao_myUpdateDate])
    {
        kakao_myUpdateDate = [NSString stringWithString:nowDate];
        [self updateMyKakaoInfo];
    }
    //(5)만약 노드값이 -1이면 노드값 업데이트
    if(-1==node) [NSThread detachNewThreadSelector:@selector(getNodeThread) toTarget:self withObject:nil];
}








/*
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    if(self.tableView == self.searchDisplayController.searchResultsTableView)
    {
        self.tableView.tableHeaderView.hidden = YES;
    }
    else
    {
        self.tableView.tableHeaderView.hidden = NO;
    }
}
*/










-(void)newAddressUpdate //'새로운 지인 추가' 업데이트
{
    isAddressUpdating = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *nowDate = [formatter stringFromDate:[NSDate date]];
    NSMutableDictionary *name_dic2 = [NSMutableDictionary dictionaryWithDictionary:name_dic];
    NSMutableDictionary *phone_dic2 = [NSMutableDictionary dictionaryWithDictionary:phone_dic];
    NSMutableDictionary *relationName_dic2 = [NSMutableDictionary dictionaryWithDictionary:relationName_dic];
    NSMutableDictionary *myLinkID_dic2 = [NSMutableDictionary dictionaryWithDictionary:myLinkID_dic];
    NSMutableDictionary *kakao_dic2 = [NSMutableDictionary dictionaryWithDictionary:kakao_dic];
    for(int i=0; i<[date_new count]; i++)
    {
        NSString *str_date = [date_new objectAtIndex:i];
        if(![str_date isEqualToString:nowDate])
        {
            NSString *str_name = [name_new objectAtIndex:i];
            NSString *str_phone = [phone_new objectAtIndex:i];
            NSString *str_relationName = [relationName_new objectAtIndex:i];
            NSString *str_myLinkID = [myLinkID_new objectAtIndex:i];
            NSString *str_kakao = [kakao_new objectAtIndex:i];
            //insert & classification
            NSArray *chosung = [NSArray arrayWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
            NSString *result_key;
            NSInteger unicodeChar = [str_name characterAtIndex:0];
            if(HANGUL_START_CODE<=unicodeChar && unicodeChar<=HANGUL_END_CODE)
            {
                result_key = [chosung objectAtIndex:(NSInteger)((unicodeChar-HANGUL_START_CODE)/(28*21))];
            }
            else if((ENG_START_CODE1<=unicodeChar && unicodeChar<=ENG_END_CODE1) || (ENG_START_CODE2<=unicodeChar && unicodeChar<=ENG_END_CODE2)) //alphabet
            {
                result_key = [str_name substringToIndex:1].uppercaseString;
            }
            else
            {
                result_key = @"#";
            }
            if([name_dic2 objectForKey:result_key]) //sort
            {
                NSMutableArray *array_name = [NSMutableArray arrayWithArray:[name_dic2 objectForKey:result_key]];
                [array_name insertObject:str_name atIndex:0];
                NSMutableArray *array_phone = [NSMutableArray arrayWithArray:[phone_dic2 objectForKey:result_key]];
                [array_phone insertObject:str_phone atIndex:0];
                NSMutableArray *array_relationName = [NSMutableArray arrayWithArray:[relationName_dic2 objectForKey:result_key]];
                [array_relationName insertObject:str_relationName atIndex:0];
                NSMutableArray *array_myLinkID = [NSMutableArray arrayWithArray:[myLinkID_dic2 objectForKey:result_key]];
                [array_myLinkID insertObject:str_myLinkID atIndex:0];
                NSMutableArray *array_kakao = [NSMutableArray arrayWithArray:[kakao_dic2 objectForKey:result_key]];
                [array_kakao insertObject:str_kakao atIndex:0];
                for(int j=0; j<[array_name count]-1; j++)
                {
                    for(int k=0; k<[array_name count]-1; k++)
                    {
                        NSString *str1 = [array_name objectAtIndex:k];
                        NSString *str2 = [array_name objectAtIndex:k+1];
                        if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                        {
                            //(1)name
                            NSString *str1_1 = [NSString stringWithString:str1];
                            NSString *str2_1 = [NSString stringWithString:str2];
                            [array_name replaceObjectAtIndex:k withObject:str2_1];
                            [array_name replaceObjectAtIndex:k+1 withObject:str1_1];
                            //(2)phone
                            str1_1 = [NSString stringWithString:[array_phone objectAtIndex:k]];
                            str2_1 = [NSString stringWithString:[array_phone objectAtIndex:k+1]];
                            [array_phone replaceObjectAtIndex:k withObject:str2_1];
                            [array_phone replaceObjectAtIndex:k+1 withObject:str1_1];
                            //(3)relationName
                            str1_1 = [NSString stringWithString:[array_relationName objectAtIndex:k]];
                            str2_1 = [NSString stringWithString:[array_relationName objectAtIndex:k+1]];
                            [array_relationName replaceObjectAtIndex:k withObject:str2_1];
                            [array_relationName replaceObjectAtIndex:k+1 withObject:str1_1];
                            //(4)myLinkID
                            str1_1 = [NSString stringWithString:[array_myLinkID objectAtIndex:k]];
                            str2_1 = [NSString stringWithString:[array_myLinkID objectAtIndex:k+1]];
                            [array_myLinkID replaceObjectAtIndex:k withObject:str2_1];
                            [array_myLinkID replaceObjectAtIndex:k+1 withObject:str1_1];
                            //(5)kakao
                            str1_1 = [NSString stringWithString:[array_kakao objectAtIndex:k]];
                            str2_1 = [NSString stringWithString:[array_kakao objectAtIndex:k+1]];
                            [array_kakao replaceObjectAtIndex:k withObject:str2_1];
                            [array_kakao replaceObjectAtIndex:k+1 withObject:str1_1];
                        }
                    }
                }
                [name_dic2 setObject:array_name forKey:result_key];
                [phone_dic2 setObject:array_phone forKey:result_key];
                [relationName_dic2 setObject:array_relationName forKey:result_key];
                [myLinkID_dic2 setObject:array_myLinkID forKey:result_key];
                [kakao_dic2 setObject:array_kakao forKey:result_key];
            }
            else
            {
                [name_dic2 setObject:[NSArray arrayWithObject:str_name] forKey:result_key];
                [phone_dic2 setObject:[NSArray arrayWithObject:str_phone] forKey:result_key];
                [relationName_dic2 setObject:[NSArray arrayWithObject:str_relationName] forKey:result_key];
                [myLinkID_dic2 setObject:[NSArray arrayWithObject:str_myLinkID] forKey:result_key];
                [kakao_dic2 setObject:[NSArray arrayWithObject:str_kakao] forKey:result_key];
            }
        }
        //delete in new
        [date_new replaceObjectAtIndex:i withObject:@"0"];
    }
    //delete in new
    NSMutableArray *date_new2;
    NSMutableArray *name_new2;
    NSMutableArray *phone_new2;
    NSMutableArray *relationName_new2;
    NSMutableArray *myLinkID_new2;
    NSMutableArray *kakao_new2;
    for(int i=0; i<[date_new count]; i++)
    {
        NSString *str_date = [date_new objectAtIndex:i];
        if(![str_date isEqualToString:@"0"])
        {
            [date_new2 addObject:[NSString stringWithString:str_date]];
            [name_new2 addObject:[NSString stringWithString:[name_new objectAtIndex:i]]];
            [relationName_new2 addObject:[NSString stringWithString:[relationName_new objectAtIndex:i]]];
            [phone_new2 addObject:[NSString stringWithString:[phone_new objectAtIndex:i]]];
            [myLinkID_new2 addObject:[NSString stringWithString:[myLinkID_new objectAtIndex:i]]];
            [kakao_new2 addObject:[NSString stringWithString:[kakao_new objectAtIndex:i]]];
        }
    }
    //dic2 -> dic
    [phone_dic removeAllObjects];
    phone_dic = [NSMutableDictionary dictionaryWithDictionary:phone_dic2];
    [name_dic removeAllObjects];
    name_dic = [NSMutableDictionary dictionaryWithDictionary:name_dic2];
    [relationName_dic removeAllObjects];
    relationName_dic = [NSMutableDictionary dictionaryWithDictionary:relationName_dic2];
    [myLinkID_dic removeAllObjects];
    myLinkID_dic = [NSMutableDictionary dictionaryWithDictionary:myLinkID_dic2];
    [kakao_dic removeAllObjects];
    kakao_dic = [NSMutableDictionary dictionaryWithDictionary:kakao_dic2];
    //new2 -> new
    [date_new removeAllObjects];
    date_new = [NSMutableArray arrayWithArray:date_new2];
    [name_new removeAllObjects];
    name_new = [NSMutableArray arrayWithArray:name_new2];
    [phone_new removeAllObjects];
    phone_new = [NSMutableArray arrayWithArray:phone_new2];
    [relationName_new removeAllObjects];
    relationName_new = [NSMutableArray arrayWithArray:relationName_new2];
    [myLinkID_new removeAllObjects];
    myLinkID_new = [NSMutableArray arrayWithArray:myLinkID_new2];
    [kakao_new removeAllObjects];
    kakao_new = [NSMutableArray arrayWithArray:kakao_new2];
    NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
    NSArray *sectionTitles_temp = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString *str in sectionTitles_temp)
    {
        [sectionIndexTitles_temp addObject:str];
        [sectionIndexTitles_temp addObject:@""];
    }
    sectionTitles = nil;
    sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
    [sectionIndexTitles removeAllObjects];
    sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
    ABAddressBookRevert(addressBookRef); //refresh addressBook
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
    //restore in file
    MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
    address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
    address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
    address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
    address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
    address2.date_new = [NSArray arrayWithArray:date_new];
    address2.name_new = [NSArray arrayWithArray:name_new];
    address2.phone_new = [NSArray arrayWithArray:phone_new];
    address2.relationName_new = [NSArray arrayWithArray:relationName_new];
    address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
    address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
    address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
    address2.name_hidden = [NSArray arrayWithArray:name_hidden];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
    [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
    //badge from new
    if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
    else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
    //title
    int cnt = 0;
    for(NSArray *array in [name_dic allValues])
    {
        cnt += [array count];
    }
    cnt += [date_new count];
    self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", cnt];
    isAddressUpdating = NO;
}
-(void)updateMyKakaoInfo
{
    //카카오에서 내 프로필 정보를 받아온다
    //(1)updated date
    NSString *updateddate = [NSString stringWithString:kakao_myUpdateDate];
    //(3)KakaoStory profile
    [KOSessionTask storyProfileTaskWithCompletionHandler:^(KOStoryProfile* profile, NSError* error)
    {
         if(profile)
         {
             NSString *story_nickname = [NSString stringWithString:profile.nickName];
             NSString *story_birth = [NSString stringWithString:profile.birthday];
             int story_birthtype = profile.birthdayType;
             NSString *story_proimg = [NSString stringWithString:profile.profileImageURL];
             NSString *story_thumb = [NSString stringWithString:profile.thumbnailURL];
             if([myKakaoUrl isEqualToString:@"0"] || 0==myKakaoUrl.length)
             {
                 myKakaoUrl = [NSString stringWithString:story_thumb];
                 //thumbnail image update
                 if(isKakaoLogin) isThumbUpdate = YES;
             }
             //if(story_thumb.length>0 && 0==myKakaoUrl.length) myKakaoUrl = [NSString stringWithString:story_thumb];
             NSString *story_bgimg = [NSString stringWithString:profile.bgImageURL];
             //NSArray *array = [NSArray arrayWithObjects:updateddate, story_nickname, story_birth, [NSNumber numberWithInt:story_birthtype], story_proimg, story_bgimg, nil];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update2:) toTarget:self withObject:array];
             NSString *story_nickname2 = [self stringByReplacingforJSON:story_nickname];
             NSString *story_proimg2 = [[[story_proimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_thumb2 = [[[story_thumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_bgimg2 = [[[story_bgimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *story_url = [[[profile.permalink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL20, myid, updateddate, story_nickname2, story_birth, story_birthtype, story_proimg2, story_thumb2, story_bgimg2, story_url];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
         }
    }];
    //(2)KakaoTalk profile
    [KOSessionTask talkProfileTaskWithCompletionHandler:^(KOTalkProfile* result, NSError* error)
    {
         if(result)
         {
             NSString *talk_nickname = [NSString stringWithString:result.nickName];
             NSString *talk_proimg = [NSString stringWithString:result.profileImageURL];
             NSString *talk_thumb = [NSString stringWithString:result.thumbnailURL];
             myKakaoUrl = [NSString stringWithString:talk_thumb];
             //thumbnail image update
             if(isKakaoLogin) isThumbUpdate = YES;
             //if(talk_thumb.length>0) myKakaoUrl = [NSString stringWithString:talk_thumb];
             //NSArray *array = [NSArray arrayWithObjects:updateddate, talk_nickname, talk_proimg, talk_thumb, nil];
             //server upload(NSThread)
             //[NSThread detachNewThreadSelector:@selector(kakao_update1:) toTarget:self withObject:array];
             NSString *talk_nickname2 = [self stringByReplacingforJSON:talk_nickname];
             NSString *talk_proimg2 = [[[talk_proimg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *talk_thumb2 = [[[talk_thumb stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
             NSString *temp = [NSString stringWithFormat:URL10, myid, updateddate, talk_nickname2, talk_proimg2, talk_thumb2];
             [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
         }
    }];
    //(4)Last story post
    [KOSessionTask storyGetMyStoriesTaskWithLastMyStoryId:nil completionHandler:^(NSArray *myStories, NSError *error)
    {
         if (!error)
         {
             for (KOStoryMyStoryInfo *myStory in myStories)
             {
                 if(0==myStory.permission || 1==myStory.permission)
                 {
                     NSString *story_content = [NSString stringWithString:myStory.content];
                     NSMutableArray *story_mediaimgs = [NSMutableArray array];
                     //3:사진이 함께 있는 경우
                     if(3==myStory.mediaType)
                     {
                         for(KOStoryMyStoryImageInfo *imgInfo in myStory.media)
                         {
                             [story_mediaimgs addObject:[NSString stringWithString:imgInfo.original]];
                         }
                     }
                     NSString *story_date = [NSString stringWithString:myStory.createdAt];
                     //NSArray *array = [NSArray arrayWithObjects:updateddate, story_content, story_mediaimgs, story_date, nil];
                     //server upload(NSThread)
                     //[NSThread detachNewThreadSelector:@selector(kakao_update3:) toTarget:self withObject:array];
                     NSMutableString *temp1 = [NSMutableString stringWithString:@""];
                     //NSMutableArray *story_mediaimgs = [NSMutableArray arrayWithArray:[array objectAtIndex:2]];
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
                     NSString *temp = [NSString stringWithFormat:URL30, myid, updateddate, story_content2, temp1, story_date];
                     [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                     break;
                 }
             }
         }
    }];
}
-(NSString *)stringByReplacingforJSON:(NSString *)str
{
    NSString *str2 = [[[[[[[str stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\\n"] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\\\""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return [NSString stringWithString:str2];
}
-(void)kakaoLoginAllUpdate
{
    NSMutableDictionary *id_dic = [NSMutableDictionary dictionary];
    NSString *temp_kakao = [NSString stringWithFormat:URL5, myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp_kakao]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *temp_str = [[result objectAtIndex:0] objectForKey:@"id"];
        if(![temp_str isEqualToString:@"0"] && ![temp_str isEqualToString:@"-1"])
        {
            for(NSDictionary *item in result)
            {
                if(![[item objectForKey:@"login"] isEqualToString:@"0"])
                {
                    [id_dic setObject:[item objectForKey:@"url"] forKey:[item objectForKey:@"id"]];
                }
            }
            //id_dic
            for(NSString *str in [myLinkID_dic allKeys])
            {
                NSArray *kakao_array = [kakao_dic objectForKey:str];
                NSMutableArray *temp_array = [myLinkID_dic objectForKey:str];
                NSMutableArray *temp_array2 = [NSMutableArray arrayWithCapacity:[temp_array count]];
                for(int i=0; i<[temp_array count]; i++)
                {
                    NSString *item = [temp_array objectAtIndex:i];
                    NSNumber *num_id = [NSNumber numberWithLongLong:[item longLongValue]];
                    if([id_dic objectForKey:item])
                    {
                        if(![[kakao_array objectAtIndex:i] isEqualToString:[id_dic objectForKey:item]]) //URL이 다르면 이미지를 새롭게 다운로드
                        {
                            [imagePool removeObjectForKey:num_id];
                        }
                        [temp_array2 addObject:[NSString stringWithString:[id_dic objectForKey:item]]];
                        [id_dic removeObjectForKey:item];
                    }
                    else
                    {
                        [imagePool removeObjectForKey:num_id];
                        [temp_array2 addObject:@"0"];
                    }
                }
                [kakao_dic setObject:temp_array2 forKey:str];
            }
            //new
            NSMutableArray *temp_array3 = [NSMutableArray arrayWithCapacity:[myLinkID_new count]];
            int cnt = 0;
            for(NSString *str in myLinkID_new)
            {
                NSNumber *num_id = [NSNumber numberWithLongLong:[str longLongValue]];
                if([id_dic objectForKey:str])
                {
                    if(![[kakao_new objectAtIndex:cnt] isEqualToString:[id_dic objectForKey:str]]) //URL이 다르면 이미지를 새롭게 다운로드
                    {
                        [imagePool removeObjectForKey:num_id];
                    }
                    [temp_array3 addObject:[NSString stringWithString:[id_dic objectForKey:str]]];
                    [id_dic removeObjectForKey:str];
                }
                else
                {
                    [imagePool removeObjectForKey:num_id];
                    [temp_array3 addObject:@"0"];
                }
                cnt++;
            }
            [kakao_new removeAllObjects];
            kakao_new = [NSMutableArray arrayWithArray:temp_array3];
        }
    }
    if(!searchController.active) [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)searchNumRefresh //검색 횟수 refresh
{
    if(curSearchNum>=maxSearchNum)
    {
        if(timer_search)
        {
            [timer_search invalidate];
            timer_search = nil;
        }
        return;
    }
    curSearchNum++;
    //label refresh in second, third
    [second.label_search setText:[NSString stringWithFormat:@"%d / %d", curSearchNum, maxSearchNum]];
    [third.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //save
    searchNumSavedDate = [NSDate date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:curSearchNum] forKey:@"cursearch"];
    [defaults setObject:searchNumSavedDate forKey:@"searchsaveddate"];
    [defaults synchronize];
    if(curSearchNum<maxSearchNum)
    {
        //loop
        [self performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:3600.0f] waitUntilDone:YES];
    }
    else
    {
        if(timer_search)
        {
            [timer_search invalidate];
            timer_search = nil;
        }
    }
}

























-(void)main1
{
    isAddressUpdating = YES;
    [alert_main performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    if(isFirst) //<1> 앱을 처음실행한 경우
    {
        NSMutableArray *name_array = [NSMutableArray array];
        NSMutableArray *phone_array = [NSMutableArray array];
        NSMutableArray *relationName_array = [NSMutableArray array];
        NSMutableArray *myLinkID_array = [NSMutableArray array];
        NSMutableArray *kakao_array = [NSMutableArray array];
        NSMutableSet *phone_set = [NSMutableSet set];   //전화번호의 유일성 유지를 위한 set
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        float step = 1.0f / (float)[allContacts count];
        int cnt = 0;
        for(id record in allContacts)
        {
            cnt++;
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            //confirm by phone number starting '01'
            ABMultiValueRef phoneRef = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
            for(int j=0; j<ABMultiValueGetCount(phoneRef); j++)
            {
                NSString *phoneNumber = nil;
                NSString *temp = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneRef, j);
                NSString *temp_1 = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString *temp_2 = [temp_1 stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSUInteger temp_length = [temp_2 length];
                if([[temp_2 substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && temp_length>=10 && temp_length<=11) phoneNumber = [NSString stringWithString:temp_2];
                else if([[temp_2 substringWithRange:NSMakeRange(0,3)] isEqualToString:@"821"] && temp_length>=11 && temp_length<=12)
                {
                    NSString *temp2 = @"01";
                    phoneNumber = [NSString stringWithString:[temp2 stringByAppendingString:[temp_2 substringFromIndex:3]]];
                }
                if(phoneNumber && (![phoneNumber isEqualToString:myPhone]) && (![phone_set containsObject:phoneNumber]))
                {
                    [phone_set addObject:phoneNumber];
                    //save in myLink server
                    NSString *temp = (__bridge NSString*)ABRecordCopyCompositeName(thisContact);
                    //NSString *temp_1 = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *temp_1 = [self stringByReplacingforJSON:temp];
                    NSString *temp2 = [NSString stringWithFormat:URL1, myid, phoneNumber, temp_1];
                    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp2]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result)
                    {
                        NSString *str_id = [result objectForKey:@"id"];
                        if([str_id longLongValue]>0)
                        {
                            [phone_array addObject:phoneNumber];
                            [name_array addObject:temp];
                            [relationName_array addObject:temp];
                            [myLinkID_array addObject:[NSString stringWithString:str_id]];
                            if([[result objectForKey:@"login"] isEqualToString:@"0"])
                            {
                                [kakao_array addObject:@"0"];
                            }
                            else
                            {
                                [kakao_array addObject:(NSString *)[result objectForKey:@"url"]]; //thumbnail image URL
                            }
                        }
                    }
                }
            }
            [self performSelectorOnMainThread:@selector(performProgress:) withObject:[NSNumber numberWithFloat:step*(float)cnt] waitUntilDone:YES];
            CFRelease(phoneRef);
            CFRelease(thisContact);
        }
        //Classfication
        NSArray *chosung = [NSArray arrayWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
        for(int i=0; i<[name_array count]; i++)
        {
            NSString *result_key;
            NSInteger unicodeChar = [[name_array objectAtIndex:i] characterAtIndex:0];
            if(HANGUL_START_CODE<=unicodeChar && unicodeChar<=HANGUL_END_CODE)
            {
                result_key = [chosung objectAtIndex:(NSInteger)((unicodeChar-HANGUL_START_CODE)/(28*21))];
            }
            else if((ENG_START_CODE1<=unicodeChar && unicodeChar<=ENG_END_CODE1) || (ENG_START_CODE2<=unicodeChar && unicodeChar<=ENG_END_CODE2)) //alphabet
            {
                result_key = [[name_array objectAtIndex:i] substringToIndex:1].uppercaseString;
            }
            else
            {
                result_key = @"#";
            }
            if([name_dic objectForKey:result_key])
            {
                [[name_dic objectForKey:result_key] addObject:[NSString stringWithString:[name_array objectAtIndex:i]]];
                [[phone_dic objectForKey:result_key] addObject:[NSString stringWithString:[phone_array objectAtIndex:i]]];
                [[relationName_dic objectForKey:result_key] addObject:[NSString stringWithString:[relationName_array objectAtIndex:i]]];
                [[myLinkID_dic objectForKey:result_key] addObject:[NSString stringWithString:[myLinkID_array objectAtIndex:i]]];
                [[kakao_dic objectForKey:result_key] addObject:[NSString stringWithString:[kakao_array objectAtIndex:i]]];
            }
            else
            {
                [name_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[name_array objectAtIndex:i]]] forKey:result_key];
                [phone_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[phone_array objectAtIndex:i]]] forKey:result_key];
                [relationName_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[relationName_array objectAtIndex:i]]] forKey:result_key];
                [myLinkID_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[myLinkID_array objectAtIndex:i]]] forKey:result_key];
                [kakao_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[kakao_array objectAtIndex:i]]] forKey:result_key];
            }
        }
        sectionTitles = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for(NSString *str in sectionTitles)
        {
            [sectionIndexTitles addObject:str];
            [sectionIndexTitles addObject:@""];
        }
        //sort names in each array
        for(NSString *str in [name_dic allKeys])
        {
            NSMutableArray *temp1 = [name_dic objectForKey:str];
            NSMutableArray *temp2 = [phone_dic objectForKey:str];
            NSMutableArray *temp3 = [relationName_dic objectForKey:str];
            NSMutableArray *temp5 = [myLinkID_dic objectForKey:str];
            NSMutableArray *temp6 = [kakao_dic objectForKey:str];
            if([temp1 count]>1)
            {
                for(int i=0; i<[temp1 count]-1; i++)
                {
                    for(int j=0; j<[temp1 count]-1; j++)
                    {
                        NSString *str1 = [temp1 objectAtIndex:j];
                        NSString *str2 = [temp1 objectAtIndex:j+1];
                        if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                        {
                            //(1)name
                            NSString *str1_1 = [NSString stringWithString:str1];
                            NSString *str2_1 = [NSString stringWithString:str2];
                            [temp1 replaceObjectAtIndex:j withObject:str2_1];
                            [temp1 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(2)phone
                            str1_1 = [NSString stringWithString:[temp2 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp2 objectAtIndex:j+1]];
                            [temp2 replaceObjectAtIndex:j withObject:str2_1];
                            [temp2 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(3)relationName
                            str1_1 = [NSString stringWithString:[temp3 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp3 objectAtIndex:j+1]];
                            [temp3 replaceObjectAtIndex:j withObject:str2_1];
                            [temp3 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(4)myLinkID
                            str1_1 = [NSString stringWithString:[temp5 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp5 objectAtIndex:j+1]];
                            [temp5 replaceObjectAtIndex:j withObject:str2_1];
                            [temp5 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(5)kakao
                            str1_1 = [NSString stringWithString:[temp6 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp6 objectAtIndex:j+1]];
                            [temp6 replaceObjectAtIndex:j withObject:str2_1];
                            [temp6 replaceObjectAtIndex:j+1 withObject:str1_1];
                        }
                    }
                }
                [name_dic setObject:temp1 forKey:str];
                [phone_dic setObject:temp2 forKey:str];
                [relationName_dic setObject:temp3 forKey:str];
                [myLinkID_dic setObject:temp5 forKey:str];
                [kakao_dic setObject:temp6 forKey:str];
            }
        }
        //init
        //isTextField = NO;
        //curInsets = self.tableView.contentInset;
        //검색 횟수
        maxSearchNum = MAXSEARCHNUM;
        curSearchNum = MAXSEARCHNUM;
        searchNumSavedDate = [NSDate date];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt:maxSearchNum] forKey:@"maxsearch"];
        [defaults setObject:[NSNumber numberWithInt:curSearchNum] forKey:@"cursearch"];
        [defaults setObject:searchNumSavedDate forKey:@"searchsaveddate"];
        [defaults synchronize];
        //self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", (int)[name_array count]];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        //restore in file
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
        MyLinkAddressBook *address = [[MyLinkAddressBook alloc] init];
        address.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
        address.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
        address.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
        address.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
        address.date_new = [NSArray arrayWithArray:date_new];
        address.name_new = [NSArray arrayWithArray:name_new];
        address.phone_new = [NSArray arrayWithArray:phone_new];
        address.relationName_new = [NSArray arrayWithArray:relationName_new];
        address.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
        address.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
        address.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
        address.name_hidden = [NSArray arrayWithArray:name_hidden];
        [NSKeyedArchiver archiveRootObject:address toFile:filePath];
    }
    else    //<2> 앱을 재실행한 경우
    {
        //(1) myLink의 전화번호와 이름을 읽어 들임
        NSMutableArray *name_array = [NSMutableArray array];
        NSMutableArray *phone_array = [NSMutableArray array];
        NSMutableArray *relationName_array = [NSMutableArray array];
        NSMutableArray *myLinkID_array = [NSMutableArray array];
        //NSMutableArray *kakao_array = [NSMutableArray array];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
        MyLinkAddressBook *address = (MyLinkAddressBook *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        for(NSString *str in [address.name_dic allKeys])
        {
            for(NSString *str2 in [address.myLinkID_dic objectForKey:str])
            {
                [myLinkID_array addObject:str2];
            }
            for(NSString *str2 in [address.name_dic objectForKey:str])
            {
                [name_array addObject:str2];
            }
            for(NSString *str2 in [address.phone_dic objectForKey:str])
            {
                [phone_array addObject:str2];
            }
            for(NSString *str2 in [address.relationName_dic objectForKey:str])
            {
                [relationName_array addObject:str2];
                //[kakao_array addObject:@"0"];
            }
        }
        //(2) 주소록의 전화번호와 이름을 읽어 들임
        NSMutableSet *phone_set = [NSMutableSet set];
        NSMutableDictionary *name_dic2 = [NSMutableDictionary dictionary];
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        for(id record in allContacts)
        {
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            //confirm by phone number starting '01'
            ABMultiValueRef phoneRef = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
            for(int j=0; j<ABMultiValueGetCount(phoneRef); j++)
            {
                NSString *phoneNumber = nil;
                NSString *temp = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneRef, j);
                NSString *temp_1 = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString *temp_2 = [temp_1 stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSUInteger temp_length = [temp_2 length];
                if([[temp_2 substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && temp_length>=10 && temp_length<=11) phoneNumber = [NSString stringWithString:temp_2];
                else if([[temp_2 substringWithRange:NSMakeRange(0,3)] isEqualToString:@"821"] && temp_length>=11 && temp_length<=12)
                {
                    NSString *temp2 = @"01";
                    phoneNumber = [NSString stringWithString:[temp2 stringByAppendingString:[temp_2 substringFromIndex:3]]];
                }
                if(phoneNumber && (![phoneNumber isEqualToString:myPhone]) && (![phone_set containsObject:phoneNumber]))
                {
                    [phone_set addObject:phoneNumber];
                    NSString *temp = (__bridge NSString*)ABRecordCopyCompositeName(thisContact);
                    [name_dic2 setObject:temp forKey:phoneNumber];
                }
            }
            CFRelease(phoneRef);
            CFRelease(thisContact);
        }
        //(3) compare
        BOOL isDelete = NO; //전화번호가 삭제되었나?
        float step = 0.8f / (float)[phone_array count];
        int cnt = 0;
        for(int i=0; i<[phone_array count]; i++)
        {
            NSString *str_phone = [phone_array objectAtIndex:i];
            long myLinkID = (long)[[myLinkID_array objectAtIndex:i] longLongValue];
            if([phone_set containsObject:str_phone]) //(3-1) 전화번호가 있는 경우
            {
                NSString *str_name = [name_array objectAtIndex:i];
                NSString *str_temp = [name_dic2 objectForKey:str_phone];
                if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
                {
                    NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:str_temp]];
                    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result)
                    {
                        if([[result objectForKey:@"result"] isEqualToString:@"1"])
                        {
                            [name_array replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                            [relationName_array replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                        }
                    }
                }
                [phone_set removeObject:str_phone];
                [name_dic2 removeObjectForKey:str_phone];
            }
            else //(3-2) 삭제된 경우
            {
                NSString *temp = [NSString stringWithFormat:URL3, myid, myLinkID];
                id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result)
                {
                    if([[result objectForKey:@"result"] isEqualToString:@"1"])
                    {
                        isDelete = YES;
                        [phone_array replaceObjectAtIndex:i withObject:@"0"];
                    }
                }
            }
            cnt++;
            [self performSelectorOnMainThread:@selector(performProgress:) withObject:[NSNumber numberWithFloat:step*(float)cnt] waitUntilDone:YES];
        }
        NSMutableArray *name_array2;
        NSMutableArray *phone_array2;
        NSMutableArray *relationName_array2;
        NSMutableArray *myLinkID_array2;
        NSMutableArray *kakao_array2;
        if(isDelete)
        {
            name_array2 = [NSMutableArray array];
            phone_array2 = [NSMutableArray array];
            relationName_array2 = [NSMutableArray array];
            myLinkID_array2 = [NSMutableArray array];
            kakao_array2 = [NSMutableArray array];
            for(int i=0; i<[phone_array count]; i++)
            {
                if(![[phone_array objectAtIndex:i] isEqualToString:@"0"])
                {
                    [phone_array2 addObject:[NSString stringWithString:[phone_array objectAtIndex:i]]];
                    [name_array2 addObject:[NSString stringWithString:[name_array objectAtIndex:i]]];
                    [relationName_array2 addObject:[NSString stringWithString:[relationName_array objectAtIndex:i]]];
                    [myLinkID_array2 addObject:[NSString stringWithString:[myLinkID_array objectAtIndex:i]]];
                    //[kakao_array2 addObject:[NSString stringWithString:[kakao_array objectAtIndex:i]]];
                    [kakao_array2 addObject:@"0"];
                }
            }
        }
        else
        {
            name_array2 = [NSMutableArray arrayWithArray:name_array];
            phone_array2 = [NSMutableArray arrayWithArray:phone_array];
            relationName_array2 = [NSMutableArray arrayWithArray:relationName_array];
            myLinkID_array2 = [NSMutableArray arrayWithArray:myLinkID_array];
            kakao_array2 = [NSMutableArray arrayWithCapacity:[phone_array count]];
            for(int i=0; i<[phone_array count]; i++)
            {
                [kakao_array2 addObject:@"0"];
            }
        }
        //new
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *nowDate = [formatter stringFromDate:[NSDate date]];
        if([address.date_new count]>0) //new가 존재하는 경우
        {
            isDelete = NO;
            NSMutableArray *date_new2 = [NSMutableArray arrayWithArray:address.date_new];
            NSMutableArray *name_new2 = [NSMutableArray arrayWithArray:address.name_new];
            NSMutableArray *phone_new2 = [NSMutableArray arrayWithArray:address.phone_new];
            NSMutableArray *relationName_new2 = [NSMutableArray arrayWithArray:address.relationName_new];
            NSMutableArray *myLinkID_new2 = [NSMutableArray arrayWithArray:address.myLinkID_new];
            for(int i=0; i<[phone_new2 count]; i++)
            {
                NSString *str_phone = [phone_new2 objectAtIndex:i];
                long myLinkID = (long)[[myLinkID_new2 objectAtIndex:i] longLongValue];
                if([phone_set containsObject:str_phone]) //전화번호가 있는 경우
                {
                    NSString *str_name = [name_new2 objectAtIndex:i];
                    NSString *str_temp = [name_dic2 objectForKey:str_phone];
                    if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
                    {
                        NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:str_temp]];
                        id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                        if(result)
                        {
                            if([[result objectForKey:@"result"] isEqualToString:@"1"])
                            {
                                [name_new2 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                                [relationName_new2 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                            }
                        }
                    }
                    [phone_set removeObject:str_phone];
                    [name_dic2 removeObjectForKey:str_phone];
                }
                else //삭제된 경우
                {
                    NSString *temp = [NSString stringWithFormat:URL3, myid, myLinkID];
                    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result)
                    {
                        if([[result objectForKey:@"result"] isEqualToString:@"1"])
                        {
                            isDelete = YES;
                            [phone_new2 replaceObjectAtIndex:i withObject:@"0"];
                        }
                    }
                }
            }
            NSMutableArray *date_new3;
            NSMutableArray *name_new3;
            NSMutableArray *phone_new3;
            NSMutableArray *relationName_new3;
            NSMutableArray *myLinkID_new3;
            if(isDelete)
            {
                date_new3 = [NSMutableArray array];
                name_new3 = [NSMutableArray array];
                phone_new3 = [NSMutableArray array];
                relationName_new3 = [NSMutableArray array];
                myLinkID_new3 = [NSMutableArray array];
                for(int i=0; i<[phone_new2 count]; i++)
                {
                    if(![[phone_new2 objectAtIndex:i] isEqualToString:@"0"])
                    {
                        [date_new3 addObject:[NSString stringWithString:[date_new2 objectAtIndex:i]]];
                        [phone_new3 addObject:[NSString stringWithString:[phone_new2 objectAtIndex:i]]];
                        [name_new3 addObject:[NSString stringWithString:[name_new2 objectAtIndex:i]]];
                        [relationName_new3 addObject:[NSString stringWithString:[relationName_new2 objectAtIndex:i]]];
                        [myLinkID_new3 addObject:[NSString stringWithString:[myLinkID_new2 objectAtIndex:i]]];
                    }
                }
            }
            else
            {
                date_new3 = [NSMutableArray arrayWithArray:date_new2];
                name_new3 = [NSMutableArray arrayWithArray:name_new2];
                phone_new3 = [NSMutableArray arrayWithArray:phone_new2];
                relationName_new3 = [NSMutableArray arrayWithArray:relationName_new2];
                myLinkID_new3 = [NSMutableArray arrayWithArray:myLinkID_new2];
            }
            for(int i=0; i<[date_new3 count]; i++)
            {
                NSString *str_new = [date_new3 objectAtIndex:i];
                if([nowDate isEqualToString:str_new])   //new에 저장
                {
                    [date_new addObject:[NSString stringWithString:str_new]];
                    [phone_new addObject:[NSString stringWithString:[phone_new3 objectAtIndex:i]]];
                    [name_new addObject:[NSString stringWithString:[name_new3 objectAtIndex:i]]];
                    [relationName_new addObject:[NSString stringWithString:[relationName_new3 objectAtIndex:i]]];
                    [myLinkID_new addObject:[NSString stringWithString:[myLinkID_new3 objectAtIndex:i]]];
                    [kakao_new addObject:@"0"];
                }
                else //array2로 이동
                {
                    [phone_array2 addObject:[NSString stringWithString:[phone_new3 objectAtIndex:i]]];
                    [name_array2 addObject:[NSString stringWithString:[name_new3 objectAtIndex:i]]];
                    [relationName_array2 addObject:[NSString stringWithString:[relationName_new3 objectAtIndex:i]]];
                    [myLinkID_array2 addObject:[NSString stringWithString:[myLinkID_new3 objectAtIndex:i]]];
                    [kakao_array2 addObject:@"0"];
                }
            }
        }
        //hidden
        NSMutableArray *myLinkID_hidden_1 = [NSMutableArray arrayWithArray:address.myLinkID_hidden];
        NSMutableArray *phone_hidden_1 = [NSMutableArray arrayWithArray:address.phone_hidden];
        NSMutableArray *name_hidden_1 = [NSMutableArray arrayWithArray:address.name_hidden];
        for(int i=0; i<[phone_hidden_1 count]; i++)
        {
            NSString *str_phone = [phone_hidden_1 objectAtIndex:i];
            if([phone_set containsObject:str_phone]) //숨김관계 전화번호가 있는 경우
            {
                NSString *str_name = [name_hidden_1 objectAtIndex:i];
                NSString *str_temp = [name_dic2 objectForKey:str_phone];
                if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
                {
                    [name_hidden_1 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                }
                [phone_set removeObject:str_phone];
                [name_dic2 removeObjectForKey:str_phone];
            }
            else //삭제된 경우
            {
                [phone_hidden_1 replaceObjectAtIndex:i withObject:@"0"];
            }
        }
        for(int i=0; i<[phone_hidden_1 count]; i++)
        {
            if(![[phone_hidden_1 objectAtIndex:i] isEqualToString:@"0"])
            {
                [phone_hidden addObject:[NSString stringWithString:[phone_hidden_1 objectAtIndex:i]]];
                [name_hidden addObject:[NSString stringWithString:[name_hidden_1 objectAtIndex:i]]];
                [myLinkID_hidden addObject:[NSString stringWithString:[myLinkID_hidden_1 objectAtIndex:i]]];
            }
        }
        //(3-3) 새로 추가된 경우 -> new에 저장
        NSArray *values = [phone_set allObjects];
        for(int i=0; i<[values count]; i++)
        {
            NSString *str_temp = [values objectAtIndex:i];
            NSString *str_temp2 = [name_dic2 objectForKey:str_temp];
            NSString *temp2 = [NSString stringWithFormat:URL1, myid, str_temp, [self stringByReplacingforJSON:str_temp2]];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp2]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                if([[result objectForKey:@"id"] longLongValue]>0)
                {
                    [date_new addObject:[NSString stringWithString:nowDate]];
                    [phone_new addObject:[NSString stringWithString:str_temp]];
                    [name_new addObject:[NSString stringWithString:str_temp2]];
                    [relationName_new addObject:[NSString stringWithString:str_temp2]];
                    [myLinkID_new addObject:[NSString stringWithString:[result objectForKey:@"id"]]];
                    [kakao_new addObject:@"0"];
                }
            }
        }
        [self performSelectorOnMainThread:@selector(performProgress:) withObject:[NSNumber numberWithFloat:0.9] waitUntilDone:YES];
        //(4)Check Kakao Login
        NSMutableDictionary *id_dic = [NSMutableDictionary dictionary];
        NSString *temp_kakao = [NSString stringWithFormat:URL5, myid];
        id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp_kakao]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
        if(result)
        {
            NSString *temp_str = [[result objectAtIndex:0] objectForKey:@"id"];
            if(![temp_str isEqualToString:@"0"] && ![temp_str isEqualToString:@"-1"])
            {
                for(NSDictionary *item in result)
                {
                    if(![[item objectForKey:@"login"] isEqualToString:@"0"])
                    {
                        [id_dic setObject:[item objectForKey:@"url"] forKey:[item objectForKey:@"id"]];
                    }
                }
                //id_dic
                for(int i=0; i<[myLinkID_array2 count]; i++)
                {
                    NSString *item = [myLinkID_array2 objectAtIndex:i];
                    if([id_dic objectForKey:item])
                    {
                        [kakao_array2 replaceObjectAtIndex:i withObject:[id_dic objectForKey:item]];
                        [id_dic removeObjectForKey:item];
                    }
                    if(0==[id_dic count]) break;
                }
                //new
                for(int i=0; i<[myLinkID_new count]; i++)
                {
                    NSString *item = [myLinkID_new objectAtIndex:i];
                    if([id_dic objectForKey:item])
                    {
                        [kakao_new replaceObjectAtIndex:i withObject:[id_dic objectForKey:item]];
                        [id_dic removeObjectForKey:item];
                    }
                    if(0==[id_dic count]) break;
                }
            }
        }
        //Classfication(new 제외)
        NSArray *chosung = [NSArray arrayWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
        for(int i=0; i<[name_array2 count]; i++)
        {
            NSString *result_key;
            NSInteger unicodeChar = [[name_array2 objectAtIndex:i] characterAtIndex:0];
            if(HANGUL_START_CODE<=unicodeChar && unicodeChar<=HANGUL_END_CODE)
            {
                result_key = [chosung objectAtIndex:(NSInteger)((unicodeChar-HANGUL_START_CODE)/(28*21))];
            }
            else if((ENG_START_CODE1<=unicodeChar && unicodeChar<=ENG_END_CODE1) || (ENG_START_CODE2<=unicodeChar && unicodeChar<=ENG_END_CODE2)) //alphabet
            {
                result_key = [[name_array2 objectAtIndex:i] substringToIndex:1].uppercaseString;
            }
            else
            {
                result_key = @"#";
            }
            if([name_dic objectForKey:result_key])
            {
                [[name_dic objectForKey:result_key] addObject:[NSString stringWithString:[name_array2 objectAtIndex:i]]];
                [[phone_dic objectForKey:result_key] addObject:[NSString stringWithString:[phone_array2 objectAtIndex:i]]];
                [[relationName_dic objectForKey:result_key] addObject:[NSString stringWithString:[relationName_array2 objectAtIndex:i]]];
                [[myLinkID_dic objectForKey:result_key] addObject:[NSString stringWithString:[myLinkID_array2 objectAtIndex:i]]];
                [[kakao_dic objectForKey:result_key] addObject:[NSString stringWithString:[kakao_array2 objectAtIndex:i]]];
            }
            else
            {
                [name_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[name_array2 objectAtIndex:i]]] forKey:result_key];
                [phone_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[phone_array2 objectAtIndex:i]]] forKey:result_key];
                [relationName_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[relationName_array2 objectAtIndex:i]]] forKey:result_key];
                [myLinkID_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[myLinkID_array2 objectAtIndex:i]]] forKey:result_key];
                [kakao_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[kakao_array2 objectAtIndex:i]]] forKey:result_key];
            }
        }
        sectionTitles = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for(NSString *str in sectionTitles)
        {
            [sectionIndexTitles addObject:str];
            [sectionIndexTitles addObject:@""];
        }
        //sort names in each array
        for(NSString *str in [name_dic allKeys])
        {
            NSMutableArray *temp1 = [name_dic objectForKey:str];
            NSMutableArray *temp2 = [phone_dic objectForKey:str];
            NSMutableArray *temp3 = [relationName_dic objectForKey:str];
            NSMutableArray *temp5 = [myLinkID_dic objectForKey:str];
            NSMutableArray *temp6 = [kakao_dic objectForKey:str];
            if([temp1 count]>1)
            {
                for(int i=0; i<[temp1 count]-1; i++)
                {
                    for(int j=0; j<[temp1 count]-1; j++)
                    {
                        NSString *str1 = [temp1 objectAtIndex:j];
                        NSString *str2 = [temp1 objectAtIndex:j+1];
                        if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                        {
                            //(1)name
                            NSString *str1_1 = [NSString stringWithString:str1];
                            NSString *str2_1 = [NSString stringWithString:str2];
                            [temp1 replaceObjectAtIndex:j withObject:str2_1];
                            [temp1 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(2)phone
                            str1_1 = [NSString stringWithString:[temp2 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp2 objectAtIndex:j+1]];
                            [temp2 replaceObjectAtIndex:j withObject:str2_1];
                            [temp2 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(3)relationName
                            str1_1 = [NSString stringWithString:[temp3 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp3 objectAtIndex:j+1]];
                            [temp3 replaceObjectAtIndex:j withObject:str2_1];
                            [temp3 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(4)myLinkID
                            str1_1 = [NSString stringWithString:[temp5 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp5 objectAtIndex:j+1]];
                            [temp5 replaceObjectAtIndex:j withObject:str2_1];
                            [temp5 replaceObjectAtIndex:j+1 withObject:str1_1];
                            //(5)kakao
                            str1_1 = [NSString stringWithString:[temp6 objectAtIndex:j]];
                            str2_1 = [NSString stringWithString:[temp6 objectAtIndex:j+1]];
                            [temp6 replaceObjectAtIndex:j withObject:str2_1];
                            [temp6 replaceObjectAtIndex:j+1 withObject:str1_1];
                        }
                    }
                }
            }
            [name_dic setObject:temp1 forKey:str];
            [phone_dic setObject:temp2 forKey:str];
            [relationName_dic setObject:temp3 forKey:str];
            [myLinkID_dic setObject:temp5 forKey:str];
            [kakao_dic setObject:temp6 forKey:str];
        }
        //init
        //isTextField = NO;
        //curInsets = self.tableView.contentInset;
        //검색 횟수
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        maxSearchNum = [[defaults objectForKey:@"maxsearch"] intValue];
        curSearchNum = [[defaults objectForKey:@"cursearch"] intValue];
        
        //for test
        //curSearchNum = 10;
        //[defaults setObject:@"10" forKey:@"cursearch"];
        //[defaults synchronize];

        searchNumSavedDate = [defaults objectForKey:@"searchsaveddate"];
        if(curSearchNum<maxSearchNum) //counting
        {
            float interval = [[NSDate date] timeIntervalSinceDate:searchNumSavedDate];
            int addValue = (int)(interval/3600.0f);
            if(curSearchNum+addValue < maxSearchNum)
            {
                NSDate *date2 = [NSDate dateWithTimeInterval:3600.0f*(float)addValue sinceDate:searchNumSavedDate];
                searchNumSavedDate = [NSDate dateWithTimeInterval:0.0f sinceDate:date2];
                [defaults setObject:searchNumSavedDate forKey:@"searchsaveddate"];
                curSearchNum += addValue;
                [defaults setObject:[NSNumber numberWithInt:curSearchNum] forKey:@"cursearch"];
                [defaults synchronize];
                [self performSelectorOnMainThread:@selector(performTimerOnMainThread:) withObject:[NSNumber numberWithFloat:(3600.0f-(interval-(float)addValue*3600.0f))] waitUntilDone:YES];
            }
            else
            {
                searchNumSavedDate = [NSDate date];
                [defaults setObject:searchNumSavedDate forKey:@"searchsaveddate"];
                curSearchNum = maxSearchNum;
                [defaults setObject:[NSNumber numberWithInt:curSearchNum] forKey:@"cursearch"];
                [defaults synchronize];
            }
        }
        //self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", (int)[name_array2 count]];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        //restore in file
        MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
        address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
        address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
        address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
        address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
        address2.date_new = [NSArray arrayWithArray:date_new];
        address2.name_new = [NSArray arrayWithArray:name_new];
        address2.phone_new = [NSArray arrayWithArray:phone_new];
        address2.relationName_new = [NSArray arrayWithArray:relationName_new];
        address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
        address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
        address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
        address2.name_hidden = [NSArray arrayWithArray:name_hidden];
        [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
    }
    [self performSelectorOnMainThread:@selector(dismissAlertMain) withObject:nil waitUntilDone:YES];
    //kakao updated date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    kakao_loginDate = [formatter stringFromDate:date];
    //badge from new
    if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
    else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
    //title
    int cnt = 0;
    for(NSArray *array in [name_dic allValues])
    {
        cnt += [array count];
    }
    cnt += [date_new count];
    self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", cnt];
    //rank update
    [NSThread detachNewThreadSelector:@selector(rankUpdateThread) toTarget:self withObject:nil];
    //get node value
    [NSThread detachNewThreadSelector:@selector(getNodeThread) toTarget:self withObject:nil];
    isAddressUpdating = NO;
}
-(void)performTimerOnMainThread:(NSNumber *)timer
{
    if(timer_search)
    {
        [timer_search invalidate];
        timer_search = nil;
    }
    //fire timer
    timer_search = [NSTimer scheduledTimerWithTimeInterval:[timer floatValue] target:self selector:@selector(searchNumRefresh) userInfo:nil repeats:NO];
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
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
/*
-(void)reloadCellImage2
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/
-(void)rankUpdateThread
{
    NSString *temp = [NSString stringWithFormat:URL7, myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        rank = [[result objectForKey:@"result"] intValue];
    }
}
-(void)getNodeThread
{
    NSString *temp = [NSString stringWithFormat:URL8, myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if(![[result objectForKey:@"node"] isEqualToString:@"-1"])
        {
            node = [[result objectForKey:@"node"] intValue];
        }
    }
}












//주소록 데이터베이스에 변동시 자동 업데이트
void addressBookUpdated(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context)
{
    //ABAddressBookRevert(reference);
    FirstViewController *viewController = (__bridge FirstViewController *)context;
    [viewController addressBookUpdated_sub];
}
-(void)addressBookUpdated_sub
{
    if(isAddressUpdating) return;
    [NSThread detachNewThreadSelector:@selector(addressBookUpdated_sub2) toTarget:self withObject:nil];
}
-(void)addressBookUpdated_sub2
{
    isAddressUpdating = YES;
    //(1) myLink의 전화번호와 이름을 읽어 들임
    NSMutableArray *name_array = [NSMutableArray array];
    NSMutableArray *phone_array = [NSMutableArray array];
    NSMutableArray *relationName_array = [NSMutableArray array];
    NSMutableArray *myLinkID_array = [NSMutableArray array];
    //NSMutableArray *kakao_array = [NSMutableArray array];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
    //MyLinkAddressBook *address = (MyLinkAddressBook *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    for(NSString *str in [name_dic allKeys])
    {
        for(NSString *str2 in [myLinkID_dic objectForKey:str])
        {
            [myLinkID_array addObject:str2];
        }
        for(NSString *str2 in [name_dic objectForKey:str])
        {
            [name_array addObject:str2];
        }
        for(NSString *str2 in [phone_dic objectForKey:str])
        {
            [phone_array addObject:str2];
        }
        for(NSString *str2 in [relationName_dic objectForKey:str])
        {
            [relationName_array addObject:str2];
            //[kakao_array addObject:@"0"];
        }
    }
    //(2) 주소록의 전화번호와 이름을 읽어 들임
    NSMutableSet *phone_set = [NSMutableSet set];
    NSMutableDictionary *name_dic2 = [NSMutableDictionary dictionary];
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for(id record in allContacts)
    {
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        //confirm by phone number starting '01'
        ABMultiValueRef phoneRef = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
        for(int j=0; j<ABMultiValueGetCount(phoneRef); j++)
        {
            NSString *phoneNumber = nil;
            NSString *temp = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneRef, j);
            NSString *temp_1 = [temp stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *temp_2 = [temp_1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSUInteger temp_length = [temp_2 length];
            if([[temp_2 substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"] && temp_length>=10 && temp_length<=11) phoneNumber = [NSString stringWithString:temp_2];
            else if([[temp_2 substringWithRange:NSMakeRange(0,3)] isEqualToString:@"821"] && temp_length>=11 && temp_length<=12)
            {
                NSString *temp2 = @"01";
                phoneNumber = [NSString stringWithString:[temp2 stringByAppendingString:[temp_2 substringFromIndex:3]]];
            }
            if(phoneNumber && (![phoneNumber isEqualToString:myPhone]) && (![phone_set containsObject:phoneNumber]))
            {
                [phone_set addObject:phoneNumber];
                NSString *temp = (__bridge NSString*)ABRecordCopyCompositeName(thisContact);
                [name_dic2 setObject:temp forKey:phoneNumber];
            }
        }
        CFRelease(phoneRef);
        CFRelease(thisContact);
    }
    //(3) compare
    BOOL isDelete = NO; //전화번호가 삭제되었나?
    //float step = 0.9f / (float)[phone_array count];
    //int cnt = 0;
    for(int i=0; i<[phone_array count]; i++)
    {
        NSString *str_phone = [phone_array objectAtIndex:i];
        long myLinkID = (long)[[myLinkID_array objectAtIndex:i] longLongValue];
        if([phone_set containsObject:str_phone]) //(3-1) 전화번호가 동일한 경우
        {
            NSString *str_name = [name_array objectAtIndex:i];
            NSString *str_temp = [name_dic2 objectForKey:str_phone];
            if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
            {
                NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:str_temp]];
                id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result)
                {
                    if([[result objectForKey:@"result"] isEqualToString:@"1"])
                    {
                        [name_array replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                        [relationName_array replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                    }
                }
            }
            [phone_set removeObject:str_phone];
            [name_dic2 removeObjectForKey:str_phone];
        }
        else //(3-2) 현재 주소록에서 삭제된 경우
        {
            NSString *temp = [NSString stringWithFormat:URL3, myid, myLinkID];
            id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
            if(result)
            {
                if([[result objectForKey:@"result"] isEqualToString:@"1"])
                {
                    isDelete = YES;
                    [phone_array replaceObjectAtIndex:i withObject:@"0"];
                }
            }
        }
        //cnt++;
        //[self performSelectorOnMainThread:@selector(performProgress:) withObject:[NSNumber numberWithFloat:step*(float)cnt] waitUntilDone:YES];
    }
    NSMutableArray *name_array2;
    NSMutableArray *phone_array2;
    NSMutableArray *relationName_array2;
    NSMutableArray *myLinkID_array2;
    NSMutableArray *kakao_array2;
    if(isDelete)
    {
        name_array2 = [NSMutableArray array];
        phone_array2 = [NSMutableArray array];
        relationName_array2 = [NSMutableArray array];
        myLinkID_array2 = [NSMutableArray array];
        kakao_array2 = [NSMutableArray array];
        for(int i=0; i<[phone_array count]; i++)
        {
            if(![[phone_array objectAtIndex:i] isEqualToString:@"0"])
            {
                [phone_array2 addObject:[NSString stringWithString:[phone_array objectAtIndex:i]]];
                [name_array2 addObject:[NSString stringWithString:[name_array objectAtIndex:i]]];
                [relationName_array2 addObject:[NSString stringWithString:[relationName_array objectAtIndex:i]]];
                [myLinkID_array2 addObject:[NSString stringWithString:[myLinkID_array objectAtIndex:i]]];
                //[kakao_array2 addObject:[NSString stringWithString:[kakao_array objectAtIndex:i]]];
                [kakao_array2 addObject:@"0"];
            }
        }
    }
    else
    {
        name_array2 = [NSMutableArray arrayWithArray:name_array];
        phone_array2 = [NSMutableArray arrayWithArray:phone_array];
        relationName_array2 = [NSMutableArray arrayWithArray:relationName_array];
        myLinkID_array2 = [NSMutableArray arrayWithArray:myLinkID_array];
        kakao_array2 = [NSMutableArray arrayWithCapacity:[phone_array count]];
        for(int i=0; i<[phone_array count]; i++)
        {
            [kakao_array2 addObject:@"0"];
        }
    }
    //new
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *nowDate = [formatter stringFromDate:[NSDate date]];
    NSMutableArray *date_new4 = [NSMutableArray array];
    NSMutableArray *name_new4 = [NSMutableArray array];
    NSMutableArray *phone_new4 = [NSMutableArray array];
    NSMutableArray *relationName_new4 = [NSMutableArray array];
    NSMutableArray *myLinkID_new4 = [NSMutableArray array];
    NSMutableArray *kakao_new4 = [NSMutableArray array];
    if([date_new count]>0) //new가 존재하는 경우
    {
        isDelete = NO;
        NSMutableArray *date_new2 = [NSMutableArray arrayWithArray:date_new];
        NSMutableArray *name_new2 = [NSMutableArray arrayWithArray:name_new];
        NSMutableArray *phone_new2 = [NSMutableArray arrayWithArray:phone_new];
        NSMutableArray *relationName_new2 = [NSMutableArray arrayWithArray:relationName_new];
        NSMutableArray *myLinkID_new2 = [NSMutableArray arrayWithArray:myLinkID_new];
        for(int i=0; i<[phone_new2 count]; i++)
        {
            NSString *str_phone = [phone_new2 objectAtIndex:i];
            long myLinkID = (long)[[myLinkID_new2 objectAtIndex:i] longLongValue];
            if([phone_set containsObject:str_phone]) //전화번호가 있는 경우
            {
                NSString *str_name = [name_new2 objectAtIndex:i];
                NSString *str_temp = [name_dic2 objectForKey:str_phone];
                if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
                {
                    NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:str_temp]];
                    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                    if(result)
                    {
                        if([[result objectForKey:@"result"] isEqualToString:@"1"])
                        {
                            [name_new2 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                            [relationName_new2 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
                        }
                    }
                }
                [phone_set removeObject:str_phone];
                [name_dic2 removeObjectForKey:str_phone];
            }
            else //삭제된 경우
            {
                NSString *temp = [NSString stringWithFormat:URL3, myid, myLinkID];
                id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
                if(result)
                {
                    if([[result objectForKey:@"result"] isEqualToString:@"1"])
                    {
                        isDelete = YES;
                        [phone_new2 replaceObjectAtIndex:i withObject:@"0"];
                    }
                }
            }
        }
        NSMutableArray *date_new3;
        NSMutableArray *name_new3;
        NSMutableArray *phone_new3;
        NSMutableArray *relationName_new3;
        NSMutableArray *myLinkID_new3;
        if(isDelete)
        {
            date_new3 = [NSMutableArray array];
            name_new3 = [NSMutableArray array];
            phone_new3 = [NSMutableArray array];
            relationName_new3 = [NSMutableArray array];
            myLinkID_new3 = [NSMutableArray array];
            for(int i=0; i<[phone_new2 count]; i++)
            {
                if(![[phone_new2 objectAtIndex:i] isEqualToString:@"0"])
                {
                    [date_new3 addObject:[NSString stringWithString:[date_new2 objectAtIndex:i]]];
                    [phone_new3 addObject:[NSString stringWithString:[phone_new2 objectAtIndex:i]]];
                    [name_new3 addObject:[NSString stringWithString:[name_new2 objectAtIndex:i]]];
                    [relationName_new3 addObject:[NSString stringWithString:[relationName_new2 objectAtIndex:i]]];
                    [myLinkID_new3 addObject:[NSString stringWithString:[myLinkID_new2 objectAtIndex:i]]];
                }
            }
        }
        else
        {
            date_new3 = [NSMutableArray arrayWithArray:date_new2];
            name_new3 = [NSMutableArray arrayWithArray:name_new2];
            phone_new3 = [NSMutableArray arrayWithArray:phone_new2];
            relationName_new3 = [NSMutableArray arrayWithArray:relationName_new2];
            myLinkID_new3 = [NSMutableArray arrayWithArray:myLinkID_new2];
        }
        for(int i=0; i<[date_new3 count]; i++)
        {
            NSString *str_new = [date_new3 objectAtIndex:i];
            if([nowDate isEqualToString:str_new])   //new에 저장
            {
                [date_new4 addObject:[NSString stringWithString:str_new]];
                [phone_new4 addObject:[NSString stringWithString:[phone_new3 objectAtIndex:i]]];
                [name_new4 addObject:[NSString stringWithString:[name_new3 objectAtIndex:i]]];
                [relationName_new4 addObject:[NSString stringWithString:[relationName_new3 objectAtIndex:i]]];
                [myLinkID_new4 addObject:[NSString stringWithString:[myLinkID_new3 objectAtIndex:i]]];
                [kakao_new4 addObject:@"0"];
            }
            else //array2로 이동
            {
                [phone_array2 addObject:[NSString stringWithString:[phone_new3 objectAtIndex:i]]];
                [name_array2 addObject:[NSString stringWithString:[name_new3 objectAtIndex:i]]];
                [relationName_array2 addObject:[NSString stringWithString:[relationName_new3 objectAtIndex:i]]];
                [myLinkID_array2 addObject:[NSString stringWithString:[myLinkID_new3 objectAtIndex:i]]];
                [kakao_array2 addObject:@"0"];
            }
        }
    }
    //hidden
    NSMutableArray *myLinkID_hidden_1 = [NSMutableArray arrayWithArray:myLinkID_hidden];
    NSMutableArray *phone_hidden_1 = [NSMutableArray arrayWithArray:phone_hidden];
    NSMutableArray *name_hidden_1 = [NSMutableArray arrayWithArray:name_hidden];
    for(int i=0; i<[phone_hidden_1 count]; i++)
    {
        NSString *str_phone = [phone_hidden_1 objectAtIndex:i];
        if([phone_set containsObject:str_phone]) //숨김관계 전화번호가 있는 경우
        {
            NSString *str_name = [name_hidden_1 objectAtIndex:i];
            NSString *str_temp = [name_dic2 objectForKey:str_phone];
            if(![str_temp isEqualToString:str_name]) //이름이 변경된 경우
            {
                [name_hidden_1 replaceObjectAtIndex:i withObject:[NSString stringWithString:str_temp]];
            }
            [phone_set removeObject:str_phone];
            [name_dic2 removeObjectForKey:str_phone];
        }
        else
        {
            [phone_hidden_1 replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    NSMutableArray *phone_hidden2 = [NSMutableArray array];
    NSMutableArray *name_hidden2 = [NSMutableArray array];
    NSMutableArray *myLinkID_hidden2 = [NSMutableArray array];
    for(int i=0; i<[phone_hidden_1 count]; i++)
    {
        if(![[phone_hidden_1 objectAtIndex:i] isEqualToString:@"0"])
        {
            [phone_hidden2 addObject:[NSString stringWithString:[phone_hidden_1 objectAtIndex:i]]];
            [name_hidden2 addObject:[NSString stringWithString:[name_hidden_1 objectAtIndex:i]]];
            [myLinkID_hidden2 addObject:[NSString stringWithString:[myLinkID_hidden_1 objectAtIndex:i]]];
        }
    }
    //(3-3) 새로 추가된 경우 -> new에 저장
    NSArray *values = [phone_set allObjects];
    for(int i=0; i<[values count]; i++)
    {
        NSString *str_temp = [values objectAtIndex:i];
        NSString *str_temp2 = [name_dic2 objectForKey:str_temp];
        NSString *temp2 = [NSString stringWithFormat:URL1, myid, str_temp, [self stringByReplacingforJSON:str_temp2]];
        id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp2]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
        if(result)
        {
            if([[result objectForKey:@"id"] longLongValue]>0)
            {
                [date_new4 addObject:[NSString stringWithString:nowDate]];
                [phone_new4 addObject:[NSString stringWithString:str_temp]];
                [name_new4 addObject:[NSString stringWithString:str_temp2]];
                [relationName_new4 addObject:[NSString stringWithString:str_temp2]];
                [myLinkID_new4 addObject:[NSString stringWithString:[result objectForKey:@"id"]]];
                //[kakao_array2 addObject:[NSString stringWithString:[result objectForKey:@"login"]]];
                [kakao_new4 addObject:@"0"];
            }
        }
    }
    //[self performSelectorOnMainThread:@selector(performProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:YES];
    //(4)Check Kakao Login
    NSMutableDictionary *id_dic = [NSMutableDictionary dictionary];
    NSString *temp_kakao = [NSString stringWithFormat:URL5, myid];
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp_kakao]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        NSString *temp_str = [[result objectAtIndex:0] objectForKey:@"id"];
        if(![temp_str isEqualToString:@"0"] && ![temp_str isEqualToString:@"-1"])
        {
            for(NSDictionary *item in result)
            {
                if(![[item objectForKey:@"login"] isEqualToString:@"0"])
                {
                    [id_dic setObject:[item objectForKey:@"url"] forKey:[item objectForKey:@"id"]];
                }
            }
            //id_dic
            for(int i=0; i<[myLinkID_array2 count]; i++)
            {
                NSString *item = [myLinkID_array2 objectAtIndex:i];
                NSNumber *num_id = [NSNumber numberWithLongLong:[item longLongValue]];
                if([id_dic objectForKey:item])
                {
                    if(![[kakao_array2 objectAtIndex:i] isEqualToString:[id_dic objectForKey:item]]) //URL이 다르면 이미지를 새롭게 다운로드
                    {
                        [imagePool removeObjectForKey:num_id];
                        [kakao_array2 replaceObjectAtIndex:i withObject:[id_dic objectForKey:item]];
                    }
                    [id_dic removeObjectForKey:item];
                }
                else
                {
                    [imagePool removeObjectForKey:num_id];
                }
            }
            //new
            for(int i=0; i<[myLinkID_new4 count]; i++)
            {
                NSString *item = [myLinkID_new4 objectAtIndex:i];
                NSNumber *num_id = [NSNumber numberWithLongLong:[item longLongValue]];
                if([id_dic objectForKey:item])
                {
                    if(![[kakao_new4 objectAtIndex:i] isEqualToString:[id_dic objectForKey:item]]) //URL이 다르면 이미지를 새롭게 다운로드
                    {
                        [imagePool removeObjectForKey:num_id];
                        [kakao_new4 replaceObjectAtIndex:i withObject:[id_dic objectForKey:item]];
                    }
                    [id_dic removeObjectForKey:item];
                }
                else
                {
                    [imagePool removeObjectForKey:num_id];
                }
            }
        }
    }
    //Classfication(new 제외)
    NSMutableDictionary *phone_dic_temp = [NSMutableDictionary dictionary];
    NSMutableDictionary *name_dic_temp = [NSMutableDictionary dictionary];
    NSMutableDictionary *relationName_dic_temp = [NSMutableDictionary dictionary];
    NSMutableDictionary *myLinkID_dic_temp = [NSMutableDictionary dictionary];
    NSMutableDictionary *kakao_dic_temp = [NSMutableDictionary dictionary];
    NSArray *chosung = [NSArray arrayWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
    for(int i=0; i<[name_array2 count]; i++)
    {
        NSString *result_key;
        NSInteger unicodeChar = [[name_array2 objectAtIndex:i] characterAtIndex:0];
        if(HANGUL_START_CODE<=unicodeChar && unicodeChar<=HANGUL_END_CODE)
        {
            result_key = [chosung objectAtIndex:(NSInteger)((unicodeChar-HANGUL_START_CODE)/(28*21))];
        }
        else if((ENG_START_CODE1<=unicodeChar && unicodeChar<=ENG_END_CODE1) || (ENG_START_CODE2<=unicodeChar && unicodeChar<=ENG_END_CODE2)) //alphabet
        {
            result_key = [[name_array2 objectAtIndex:i] substringToIndex:1].uppercaseString;
        }
        else
        {
            result_key = @"#";
        }
        if([name_dic_temp objectForKey:result_key])
        {
            [[name_dic_temp objectForKey:result_key] addObject:[NSString stringWithString:[name_array2 objectAtIndex:i]]];
            [[phone_dic_temp objectForKey:result_key] addObject:[NSString stringWithString:[phone_array2 objectAtIndex:i]]];
            [[relationName_dic_temp objectForKey:result_key] addObject:[NSString stringWithString:[relationName_array2 objectAtIndex:i]]];
            [[myLinkID_dic_temp objectForKey:result_key] addObject:[NSString stringWithString:[myLinkID_array2 objectAtIndex:i]]];
            [[kakao_dic_temp objectForKey:result_key] addObject:[NSString stringWithString:[kakao_array2 objectAtIndex:i]]];
        }
        else
        {
            [name_dic_temp setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[name_array2 objectAtIndex:i]]] forKey:result_key];
            [phone_dic_temp setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[phone_array2 objectAtIndex:i]]] forKey:result_key];
            [relationName_dic_temp setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[relationName_array2 objectAtIndex:i]]] forKey:result_key];
            [myLinkID_dic_temp setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[myLinkID_array2 objectAtIndex:i]]] forKey:result_key];
            [kakao_dic_temp setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:[kakao_array2 objectAtIndex:i]]] forKey:result_key];
        }
    }
    NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
    NSArray *sectionTitles_temp = [[name_dic_temp allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString *str in sectionTitles_temp)
    {
        [sectionIndexTitles_temp addObject:str];
        [sectionIndexTitles_temp addObject:@""];
    }
    //sort names in each array
    for(NSString *str in [name_dic_temp allKeys])
    {
        NSMutableArray *temp1 = [name_dic_temp objectForKey:str];
        NSMutableArray *temp2 = [phone_dic_temp objectForKey:str];
        NSMutableArray *temp3 = [relationName_dic_temp objectForKey:str];
        NSMutableArray *temp5 = [myLinkID_dic_temp objectForKey:str];
        NSMutableArray *temp6 = [kakao_dic_temp objectForKey:str];
        if([temp1 count]>1)
        {
            for(int i=0; i<[temp1 count]-1; i++)
            {
                for(int j=0; j<[temp1 count]-1; j++)
                {
                    NSString *str1 = [temp1 objectAtIndex:j];
                    NSString *str2 = [temp1 objectAtIndex:j+1];
                    if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                    {
                        //(1)name
                        NSString *str1_1 = [NSString stringWithString:str1];
                        NSString *str2_1 = [NSString stringWithString:str2];
                        [temp1 replaceObjectAtIndex:j withObject:str2_1];
                        [temp1 replaceObjectAtIndex:j+1 withObject:str1_1];
                        //(2)phone
                        str1_1 = [NSString stringWithString:[temp2 objectAtIndex:j]];
                        str2_1 = [NSString stringWithString:[temp2 objectAtIndex:j+1]];
                        [temp2 replaceObjectAtIndex:j withObject:str2_1];
                        [temp2 replaceObjectAtIndex:j+1 withObject:str1_1];
                        //(3)relationName
                        str1_1 = [NSString stringWithString:[temp3 objectAtIndex:j]];
                        str2_1 = [NSString stringWithString:[temp3 objectAtIndex:j+1]];
                        [temp3 replaceObjectAtIndex:j withObject:str2_1];
                        [temp3 replaceObjectAtIndex:j+1 withObject:str1_1];
                        //(4)myLinkID
                        str1_1 = [NSString stringWithString:[temp5 objectAtIndex:j]];
                        str2_1 = [NSString stringWithString:[temp5 objectAtIndex:j+1]];
                        [temp5 replaceObjectAtIndex:j withObject:str2_1];
                        [temp5 replaceObjectAtIndex:j+1 withObject:str1_1];
                        //(5)kakao
                        str1_1 = [NSString stringWithString:[temp6 objectAtIndex:j]];
                        str2_1 = [NSString stringWithString:[temp6 objectAtIndex:j+1]];
                        [temp6 replaceObjectAtIndex:j withObject:str2_1];
                        [temp6 replaceObjectAtIndex:j+1 withObject:str1_1];
                    }
                }
            }
            [name_dic_temp setObject:temp1 forKey:str];
            [phone_dic_temp setObject:temp2 forKey:str];
            [relationName_dic_temp setObject:temp3 forKey:str];
            [myLinkID_dic_temp setObject:temp5 forKey:str];
            [kakao_dic_temp setObject:temp6 forKey:str];
        }
    }
    //init
    //isTextField = NO;
    //curInsets = self.tableView.contentInset;
    //isSearching = NO;
    [self.navigationItem performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%d명의 지인", (int)[name_array2 count]] waitUntilDone:YES];
    [phone_dic removeAllObjects];
    phone_dic = [NSMutableDictionary dictionaryWithDictionary:phone_dic_temp];
    [name_dic removeAllObjects];
    name_dic = [NSMutableDictionary dictionaryWithDictionary:name_dic_temp];
    [relationName_dic removeAllObjects];
    relationName_dic = [NSMutableDictionary dictionaryWithDictionary:relationName_dic_temp];
    [myLinkID_dic removeAllObjects];
    myLinkID_dic = [NSMutableDictionary dictionaryWithDictionary:myLinkID_dic_temp];
    [kakao_dic removeAllObjects];
    kakao_dic = [NSMutableDictionary dictionaryWithDictionary:kakao_dic_temp];
    //new
    [date_new removeAllObjects];
    date_new = [NSMutableArray arrayWithArray:date_new4];
    [name_new removeAllObjects];
    name_new = [NSMutableArray arrayWithArray:name_new4];
    [phone_new removeAllObjects];
    phone_new = [NSMutableArray arrayWithArray:phone_new4];
    [relationName_new removeAllObjects];
    relationName_new = [NSMutableArray arrayWithArray:relationName_new4];
    [myLinkID_new removeAllObjects];
    myLinkID_new = [NSMutableArray arrayWithArray:myLinkID_new4];
    [kakao_new removeAllObjects];
    kakao_new = [NSMutableArray arrayWithArray:kakao_new4];
    //hidden
    [myLinkID_hidden removeAllObjects];
    myLinkID_hidden = [NSMutableArray arrayWithArray:myLinkID_hidden2];
    [phone_hidden removeAllObjects];
    phone_hidden = [NSMutableArray arrayWithArray:phone_hidden2];
    [name_hidden removeAllObjects];
    name_hidden = [NSMutableArray arrayWithArray:name_hidden2];
    sectionTitles = nil;
    sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
    [sectionIndexTitles removeAllObjects];
    sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
    ABAddressBookRevert(addressBookRef); //refresh addressBook
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
    //restore in file
    MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
    address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
    address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
    address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
    address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
    address2.date_new = [NSArray arrayWithArray:date_new];
    address2.name_new = [NSArray arrayWithArray:name_new];
    address2.phone_new = [NSArray arrayWithArray:phone_new];
    address2.relationName_new = [NSArray arrayWithArray:relationName_new];
    address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
    address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
    address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
    address2.name_hidden = [NSArray arrayWithArray:name_hidden];
    [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
    //badge from new
    if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
    else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
    //title
    int cnt = 0;
    for(NSArray *array in [name_dic allValues])
    {
        cnt += [array count];
    }
    cnt += [date_new count];
    self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", cnt];
    //rank update
    [NSThread detachNewThreadSelector:@selector(rankUpdateThread) toTarget:self withObject:nil];
    isAddressUpdating = NO;
}


























//tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView2
{
    if(searchController.active) return 1;
    else
    {
        if([date_new count]>0) return [sectionTitles count]+2;
        else return [sectionTitles count]+1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView2 numberOfRowsInSection:(NSInteger)section
{
    if(searchController.active) return [searchResults_keys count];
    else
    {
        if(0==section) return 1;
        else
        {
            if([date_new count]>0)
            {
                if(1==section) return [date_new count];
                else
                {
                    if([sectionTitles count]>0) return [[name_dic objectForKey:[sectionTitles objectAtIndex:section-2]] count];
                    else return 0;
                }
            }
            else
            {
                if([sectionTitles count]>0) return [[name_dic objectForKey:[sectionTitles objectAtIndex:section-1]] count];
                else return 0;
            }
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView2 heightForHeaderInSection:(NSInteger)section
{
    if(searchController.active) return 0.1f;
    else
    {
        if(0==section) return 0.1f;
        else return 30.0f;
    }
}
/*
-(NSString *)tableView:(UITableView *)tableView2 titleForHeaderInSection:(NSInteger)section
{
    if(tableView2 == self.searchDisplayController.searchResultsTableView) return nil;
    else
    {
        if(0==section) return nil;
        else
        {
            if([date_new count]>0)
            {
                if(1==section) return @"새로 추가된 지인";
                else return [sectionTitles objectAtIndex:section-2];
            }
            else return [sectionTitles objectAtIndex:section-1];
        }
    }
}
*/
-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    if(searchController.active) return nil;
    else
    {
        if(0==section) return nil;
        else
        {
            if([date_new count]>0)
            {
                if(1==section)
                {
                    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
                    tempView.backgroundColor = [UIColor whiteColor];
                    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(45,0,250,30)];
                    tempLabel.backgroundColor = [UIColor clearColor];
                    tempLabel.textColor = [UIColor redColor];
                    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
                    tempLabel.text = @"새로 추가된 지인";
                    [tempView addSubview:tempLabel];
                    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
                    imageView1.backgroundColor = [UIColor lightGrayColor];
                    imageView1.alpha = 0.5f;
                    [tempView addSubview:imageView1];
                    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, self.view.frame.size.width, 1.0f)];
                    imageView2.backgroundColor = [UIColor lightGrayColor];
                    imageView2.alpha = 0.5f;
                    [tempView addSubview:imageView2];
                    return tempView;
                }
                else
                {
                    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
                    tempView.backgroundColor = [UIColor whiteColor];
                    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(45,0,250,30)];
                    tempLabel.backgroundColor = [UIColor clearColor];
                    tempLabel.textColor = [UIColor blackColor];
                    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
                    tempLabel.text = [sectionTitles objectAtIndex:section-2];
                    [tempView addSubview:tempLabel];
                    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
                    imageView1.backgroundColor = [UIColor lightGrayColor];
                    imageView1.alpha = 0.5f;
                    [tempView addSubview:imageView1];
                    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, self.view.frame.size.width, 1.0f)];
                    imageView2.backgroundColor = [UIColor lightGrayColor];
                    imageView2.alpha = 0.5f;
                    [tempView addSubview:imageView2];
                    return tempView;
                }
            }
            else
            {
                UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
                tempView.backgroundColor = [UIColor whiteColor];
                UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(45,0,250,30)];
                tempLabel.backgroundColor = [UIColor clearColor];
                tempLabel.textColor = [UIColor blackColor];
                tempLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
                tempLabel.text = [sectionTitles objectAtIndex:section-1];
                [tempView addSubview:tempLabel];
                UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f)];
                imageView1.backgroundColor = [UIColor lightGrayColor];
                imageView1.alpha = 0.5f;
                [tempView addSubview:imageView1];
                UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 29.0f, self.view.frame.size.width, 1.0f)];
                imageView2.backgroundColor = [UIColor lightGrayColor];
                imageView2.alpha = 0.5f;
                [tempView addSubview:imageView2];
                return tempView;
            }
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(searchController.active)
    {
        CustomCell_1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL_1"];
        NSString *mykey = [searchResults_keys objectAtIndex:indexPath.row];
        NSString *key = [searchResultDic_key objectForKey:mykey];
        NSString *num = [searchResultDic_num objectForKey:mykey];
        int index = [num intValue];
        if([key isEqualToString:@"new"])
        {
            NSString *str_kakao = [kakao_new objectAtIndex:index];
            if([str_kakao isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
            else if(0==[str_kakao length])
            {
                cell.cell_imageView.hidden = NO;
                cell.cell_imageView.image = empty_img;
            }
            else //이미지 URL이 존재하는 경우
            {
                NSNumber *num_id = [NSNumber numberWithLongLong:[[myLinkID_new objectAtIndex:index] longLongValue]];
                UIImage *image = [imagePool objectForKey:num_id];
                if([image isMemberOfClass:[UIImage class]])
                {
                    cell.cell_imageView.hidden = NO;
                    cell.cell_imageView.image = image;
                }
                else if(nil==image)
                {
                    CellImageDownloader *down = [[CellImageDownloader alloc] init];
                    down.delegate2 = self;
                    down.urlStr = str_kakao;
                    down.indexPath = indexPath;
                    down.num = num_id;
                    [downloaderQueue addOperation:down];
                    [imagePool setObject:[NSNull null] forKey:num_id];
                }
            }
            cell.cell_label.text = [name_new objectAtIndex:index];
            cell.cell_textField.text = [relationName_new objectAtIndex:index];
        }
        else
        {
            NSString *str_kakao = [[kakao_dic objectForKey:key] objectAtIndex:index];
            if([str_kakao isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
            else if(0==[str_kakao length])
            {
                cell.cell_imageView.hidden = NO;
                cell.cell_imageView.image = empty_img;
            }
            else //이미지 URL이 존재하는 경우
            {
                NSNumber *num_id = [NSNumber numberWithLongLong:[[[myLinkID_dic objectForKey:key] objectAtIndex:index] longLongValue]];
                UIImage *image = [imagePool objectForKey:num_id];
                if([image isMemberOfClass:[UIImage class]])
                {
                    cell.cell_imageView.hidden = NO;
                    cell.cell_imageView.image = image;
                }
                else if(nil==image)
                {
                    CellImageDownloader *down = [[CellImageDownloader alloc] init];
                    down.delegate2 = self;
                    down.urlStr = str_kakao;
                    down.indexPath = indexPath;
                    down.num = num_id;
                    [downloaderQueue addOperation:down];
                    [imagePool setObject:[NSNull null] forKey:num_id];
                }
            }
            cell.cell_label.text = [[name_dic objectForKey:key] objectAtIndex:index];
            cell.cell_textField.text = [[relationName_dic objectForKey:key] objectAtIndex:index];
        }
        cell.cell_textField.delegate = self;
        cell.cell_textField.returnKeyType = UIReturnKeyDone;
        return cell;
    }
    else
    {
        if(0==indexPath.section)
        {
            CustomCell_1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL_2"];
            NSString *temp1 = [myPhone substringToIndex:3];
            NSRange r;
            NSString *temp3;
            if(11==[myPhone length])
            {
                r = NSMakeRange(3, 4);
                temp3 = [myPhone substringFromIndex:7];
            }
            else
            {
                r = NSMakeRange(3, 3);
                temp3 = [myPhone substringFromIndex:6];
            }
            NSString *temp2 = [myPhone substringWithRange:r];
            cell.cell_label.text = [NSString stringWithFormat:@"나의 전화번호: %@-%@-%@", temp1, temp2, temp3];
            if(isKakaoLogin)
            {
                if([myKakaoUrl isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
                else if(0==myKakaoUrl.length)
                {
                    cell.cell_imageView.hidden = NO;
                    cell.cell_imageView.image = empty_img;
                }
                /*
                if(0==myKakaoUrl.length)
                {
                    cell.cell_imageView.hidden = NO;
                    cell.cell_imageView.image = empty_img;
                }
                */
                else
                {
                    NSNumber *num_id = [NSNumber numberWithLong:myid];
                    UIImage *image = [imagePool objectForKey:num_id];
                    if([image isMemberOfClass:[UIImage class]])
                    {
                        cell.cell_imageView.hidden = NO;
                        cell.cell_imageView.image = image;
                    }
                    else if(nil==image)
                    {
                        CellImageDownloader *down = [[CellImageDownloader alloc] init];
                        down.delegate2 = self;
                        down.urlStr = myKakaoUrl;
                        down.indexPath = indexPath;
                        down.num = num_id;
                        [downloaderQueue addOperation:down];
                        [imagePool setObject:[NSNull null] forKey:num_id];
                    }
                }
            }
            else cell.cell_imageView.hidden = YES;
            return cell;
        }
        else
        {
            if([date_new count]>0)
            {
                if(1==indexPath.section)
                {
                    CustomCell_1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL_1"];
                    NSString *str_kakao = [kakao_new objectAtIndex:indexPath.row];
                    if([str_kakao isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
                    else if(0==[str_kakao length])
                    {
                        cell.cell_imageView.hidden = NO;
                        cell.cell_imageView.image = empty_img;
                    }
                    else //이미지 URL이 존재하는 경우
                    {
                        NSNumber *num_id = [NSNumber numberWithLongLong:[[myLinkID_new objectAtIndex:indexPath.row] longLongValue]];
                        UIImage *image = [imagePool objectForKey:num_id];
                        if([image isMemberOfClass:[UIImage class]])
                        {
                            cell.cell_imageView.hidden = NO;
                            cell.cell_imageView.image = image;
                        }
                        else if(nil==image)
                        {
                            CellImageDownloader *down = [[CellImageDownloader alloc] init];
                            down.delegate2 = self;
                            down.urlStr = str_kakao;
                            down.indexPath = indexPath;
                            down.num = num_id;
                            [downloaderQueue addOperation:down];
                            [imagePool setObject:[NSNull null] forKey:num_id];
                        }
                    }
                    cell.cell_label.text = [name_new objectAtIndex:indexPath.row];
                    cell.cell_textField.delegate = self;
                    cell.cell_textField.returnKeyType = UIReturnKeyDone;
                    cell.cell_textField.text = [relationName_new objectAtIndex:indexPath.row];
                    return cell;
                }
                else
                {
                    CustomCell_1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL_1"];
                    NSString *temp = [sectionTitles objectAtIndex:indexPath.section-2];
                    NSString *str_kakao = [[kakao_dic objectForKey:temp] objectAtIndex:indexPath.row];
                    if([str_kakao isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
                    else if(0==[str_kakao length])
                    {
                        cell.cell_imageView.hidden = NO;
                        cell.cell_imageView.image = empty_img;
                    }
                    else //이미지 URL이 존재하는 경우
                    {
                        NSNumber *num_id = [NSNumber numberWithLongLong:[[[myLinkID_dic objectForKey:temp] objectAtIndex:indexPath.row] longLongValue]];
                        UIImage *image = [imagePool objectForKey:num_id];
                        if([image isMemberOfClass:[UIImage class]])
                        {
                            cell.cell_imageView.hidden = NO;
                            cell.cell_imageView.image = image;
                        }
                        else if(nil==image)
                        {
                            CellImageDownloader *down = [[CellImageDownloader alloc] init];
                            down.delegate2 = self;
                            down.urlStr = str_kakao;
                            down.indexPath = indexPath;
                            down.num = num_id;
                            [downloaderQueue addOperation:down];
                            [imagePool setObject:[NSNull null] forKey:num_id];
                        }
                    }
                    cell.cell_label.text = [[name_dic objectForKey:temp] objectAtIndex:indexPath.row];
                    cell.cell_textField.delegate = self;
                    cell.cell_textField.returnKeyType = UIReturnKeyDone;
                    cell.cell_textField.text = [[relationName_dic objectForKey:temp] objectAtIndex:indexPath.row];
                    return cell;
                }
            }
            else
            {
                CustomCell_1 *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL_1"];
                NSString *temp = [sectionTitles objectAtIndex:indexPath.section-1];
                NSString *str_kakao = [[kakao_dic objectForKey:temp] objectAtIndex:indexPath.row];
                if([str_kakao isEqualToString:@"0"]) cell.cell_imageView.hidden = YES;
                else if(0==[str_kakao length])
                {
                    cell.cell_imageView.hidden = NO;
                    cell.cell_imageView.image = empty_img;
                }
                else //이미지 URL이 존재하는 경우
                {
                    NSNumber *num_id = [NSNumber numberWithLongLong:[[[myLinkID_dic objectForKey:temp] objectAtIndex:indexPath.row] longLongValue]];
                    UIImage *image = [imagePool objectForKey:num_id];
                    if([image isMemberOfClass:[UIImage class]])
                    {
                        cell.cell_imageView.hidden = NO;
                        cell.cell_imageView.image = image;
                    }
                    else if(nil==image)
                    {
                        CellImageDownloader *down = [[CellImageDownloader alloc] init];
                        down.delegate2 = self;
                        down.urlStr = str_kakao;
                        down.indexPath = indexPath;
                        down.num = num_id;
                        [downloaderQueue addOperation:down];
                        [imagePool setObject:[NSNull null] forKey:num_id];
                    }
                }
                cell.cell_label.text = [[name_dic objectForKey:temp] objectAtIndex:indexPath.row];
                cell.cell_textField.delegate = self;
                cell.cell_textField.returnKeyType = UIReturnKeyDone;
                cell.cell_textField.text = [[relationName_dic objectForKey:temp] objectAtIndex:indexPath.row];
                return cell;
            }
        }
    }
}
//section index titles
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView2
{
    if(searchController.active) return nil;
    else return sectionIndexTitles;
}
-(NSInteger)tableView:(UITableView *)tableView2 sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(searchController.active) return 0;
    else
    {
        if([date_new count]>0) return [sectionTitles indexOfObject:title]+2;
        else return [sectionTitles indexOfObject:title]+1;
    }
}















//cell selection
-(void)tableView:(UITableView *)tableView2 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView2 deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo_ViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"USERINFO"];
    user.first = self;
    if(searchController.active)
    {
        user.flag = 1;
        NSString *mykey = [searchResults_keys objectAtIndex:indexPath.row];
        NSString *key = [searchResultDic_key objectForKey:mykey];
        NSString *num = [searchResultDic_num objectForKey:mykey];
        int index = [num intValue];
        if([key isEqualToString:@"new"])
        {
            user.name = [name_new objectAtIndex:index];
            user.relationName = [relationName_new objectAtIndex:index];
            NSString *phone = [phone_new objectAtIndex:index];
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
            user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
            user.user_id = (long)[mykey longLongValue];
        }
        else
        {
            user.name = [[name_dic objectForKey:key] objectAtIndex:index];
            user.relationName = [[relationName_dic objectForKey:key] objectAtIndex:index];
            NSString *phone = [[phone_dic objectForKey:key] objectAtIndex:index];
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
            user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
            user.user_id = (long)[mykey longLongValue];
        }
    }
    else
    {
        if(0==indexPath.section && 0==indexPath.row)
        {
            user.flag = 0;
            user.user_id = myid;
        }
        else
        {
            if([date_new count]>0)
            {
                if(1==indexPath.section)
                {
                    user.flag = 1;
                    user.name = [name_new objectAtIndex:indexPath.row];
                    user.relationName = [relationName_new objectAtIndex:indexPath.row];
                    NSString *phone = [phone_new objectAtIndex:indexPath.row];
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
                    user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
                    user.user_id = (long)[myLinkID_new objectAtIndex:indexPath.row];
                }
                else
                {
                    user.flag = 1;
                    NSString *temp = [sectionTitles objectAtIndex:indexPath.section-2];
                    user.name = [[name_dic objectForKey:temp] objectAtIndex:indexPath.row];
                    user.relationName = [[relationName_dic objectForKey:temp] objectAtIndex:indexPath.row];
                    NSString *phone = [[phone_dic objectForKey:temp] objectAtIndex:indexPath.row];
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
                    user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
                    user.user_id = (long)[[[myLinkID_dic objectForKey:temp] objectAtIndex:indexPath.row] longLongValue];
                }
            }
            else
            {
                user.flag = 1;
                NSString *temp = [sectionTitles objectAtIndex:indexPath.section-1];
                user.name = [[name_dic objectForKey:temp] objectAtIndex:indexPath.row];
                user.relationName = [[relationName_dic objectForKey:temp] objectAtIndex:indexPath.row];
                NSString *phone = [[phone_dic objectForKey:temp] objectAtIndex:indexPath.row];
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
                user.phone = [NSString stringWithFormat:@"%@-%@-%@", temp1, temp2, temp3];
                user.user_id = (long)[[[myLinkID_dic objectForKey:temp] objectAtIndex:indexPath.row] longLongValue];
            }
        }
    }
    [self.navigationController pushViewController:user animated:YES];
}

















//숨김관계
- (IBAction)hiddenBtnClicked:(id)sender
{
    self.tableView.editing = !self.tableView.editing;
    ((UIBarButtonItem *)sender).title = self.tableView.editing? @"완료" : @"숨김설정";
    //badge from new
    if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
    else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"숨김";
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView2 editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(searchController.active)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        if(0==indexPath.section) return UITableViewCellEditingStyleNone;
        else return UITableViewCellEditingStyleDelete;
    }
}
-(void)tableView:(UITableView *)tableView2 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        if(searchController.active)
        {
            NSString *myLinkID = [searchResults_keys objectAtIndex:indexPath.row];
            NSString *key = [searchResultDic_key objectForKey:myLinkID];
            NSString *num = [searchResultDic_num objectForKey:myLinkID];
            int index = [num intValue];
            if([key isEqualToString:@"new"])//new
            {
                NSString *name = [name_new objectAtIndex:index];
                NSString *phone = [phone_new objectAtIndex:index];
                //(1)add
                [name_hidden addObject:[NSString stringWithString:name]];
                [phone_hidden addObject:[NSString stringWithString:phone]];
                [myLinkID_hidden addObject:[NSString stringWithString:myLinkID]];
                //(2)remove
                [date_new removeObjectAtIndex:index];
                [name_new removeObjectAtIndex:index];
                [phone_new removeObjectAtIndex:index];
                [relationName_new removeObjectAtIndex:index];
                [myLinkID_new removeObjectAtIndex:index];
                [kakao_new removeObjectAtIndex:index];
            }
            else
            {
                NSString *name = [[name_dic objectForKey:key] objectAtIndex:index];
                NSString *phone = [[phone_dic objectForKey:key] objectAtIndex:index];
                //(1)add
                [name_hidden addObject:[NSString stringWithString:name]];
                [phone_hidden addObject:[NSString stringWithString:phone]];
                [myLinkID_hidden addObject:[NSString stringWithString:myLinkID]];
                //(2)remove
                if(1==[[name_dic objectForKey:key] count])
                {
                    [name_dic removeObjectForKey:key];
                    [phone_dic removeObjectForKey:key];
                    [relationName_dic removeObjectForKey:key];
                    [myLinkID_dic removeObjectForKey:key];
                    [kakao_dic removeObjectForKey:key];
                }
                else
                {
                    [[name_dic objectForKey:key] removeObjectAtIndex:index];
                    [[phone_dic objectForKey:key] removeObjectAtIndex:index];
                    [[relationName_dic objectForKey:key] removeObjectAtIndex:index];
                    [[myLinkID_dic objectForKey:key] removeObjectAtIndex:index];
                    [[kakao_dic objectForKey:key] removeObjectAtIndex:index];
                }
                //section index
                NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
                NSArray *sectionTitles_temp = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                for(NSString *str in sectionTitles_temp)
                {
                    [sectionIndexTitles_temp addObject:str];
                    [sectionIndexTitles_temp addObject:@""];
                }
                sectionTitles = nil;
                sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
                [sectionIndexTitles removeAllObjects];
                sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
                [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
            }
            //search result
            [self filterContentForSearchText:searchController.searchBar.text scope:[[searchController.searchBar scopeButtonTitles] objectAtIndex:[searchController.searchBar selectedScopeButtonIndex]]];
            //[self.tableView reloadData];
            //[searchResultDic_key removeObjectForKey:myLinkID];
            //[searchResultDic_num removeObjectForKey:myLinkID];
            //[searchResults_keys removeObjectAtIndex:indexPath.row];
            //save in file
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
            MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
            address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
            address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
            address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
            address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
            address2.date_new = [NSArray arrayWithArray:date_new];
            address2.name_new = [NSArray arrayWithArray:name_new];
            address2.phone_new = [NSArray arrayWithArray:phone_new];
            address2.relationName_new = [NSArray arrayWithArray:relationName_new];
            address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
            address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
            address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
            address2.name_hidden = [NSArray arrayWithArray:name_hidden];
            [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
            //badge from new
            if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
            else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
            //title
            int cnt = 0;
            for(NSArray *array in [name_dic allValues])
            {
                cnt += [array count];
            }
            cnt += [date_new count];
            self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", cnt];
            [tableView2 reloadData];
            [NSThread detachNewThreadSelector:@selector(hiddenBtnClicked_thread:) toTarget:self withObject:myLinkID];
        }
        else
        {
            NSString *myLinkID;
            if([date_new count]>0) //new
            {
                if(1==indexPath.section)
                {
                    NSString *name = [name_new objectAtIndex:indexPath.row];
                    NSString *phone = [phone_new objectAtIndex:indexPath.row];
                    myLinkID = [myLinkID_new objectAtIndex:indexPath.row];
                    //(1)add
                    [name_hidden addObject:[NSString stringWithString:name]];
                    [phone_hidden addObject:[NSString stringWithString:phone]];
                    [myLinkID_hidden addObject:[NSString stringWithString:myLinkID]];
                    //(2)remove
                    [date_new removeObjectAtIndex:indexPath.row];
                    [name_new removeObjectAtIndex:indexPath.row];
                    [phone_new removeObjectAtIndex:indexPath.row];
                    [relationName_new removeObjectAtIndex:indexPath.row];
                    [myLinkID_new removeObjectAtIndex:indexPath.row];
                    [kakao_new removeObjectAtIndex:indexPath.row];
                }
                else
                {
                    NSString *key = [sectionTitles objectAtIndex:indexPath.section-2];
                    NSString *name = [[name_dic objectForKey:key] objectAtIndex:indexPath.row];
                    NSString *phone = [[phone_dic objectForKey:key] objectAtIndex:indexPath.row];
                    myLinkID = [[myLinkID_dic objectForKey:key] objectAtIndex:indexPath.row];
                    //(1)add
                    [name_hidden addObject:[NSString stringWithString:name]];
                    [phone_hidden addObject:[NSString stringWithString:phone]];
                    [myLinkID_hidden addObject:[NSString stringWithString:myLinkID]];
                    //(2)remove
                    if(1==[[name_dic objectForKey:key] count])
                    {
                        [name_dic removeObjectForKey:key];
                        [phone_dic removeObjectForKey:key];
                        [relationName_dic removeObjectForKey:key];
                        [myLinkID_dic removeObjectForKey:key];
                        [kakao_dic removeObjectForKey:key];
                    }
                    else
                    {
                        [[name_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                        [[phone_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                        [[relationName_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                        [[myLinkID_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                        [[kakao_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                    }
                    //section index
                    NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
                    NSArray *sectionTitles_temp = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                    for(NSString *str in sectionTitles_temp)
                    {
                        [sectionIndexTitles_temp addObject:str];
                        [sectionIndexTitles_temp addObject:@""];
                    }
                    sectionTitles = nil;
                    sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
                    [sectionIndexTitles removeAllObjects];
                    sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
                    [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
                }
            }
            else
            {
                NSString *key = [sectionTitles objectAtIndex:indexPath.section-1];
                NSString *name = [[name_dic objectForKey:key] objectAtIndex:indexPath.row];
                NSString *phone = [[phone_dic objectForKey:key] objectAtIndex:indexPath.row];
                myLinkID = [[myLinkID_dic objectForKey:key] objectAtIndex:indexPath.row];
                //(1)add
                [name_hidden addObject:[NSString stringWithString:name]];
                [phone_hidden addObject:[NSString stringWithString:phone]];
                [myLinkID_hidden addObject:[NSString stringWithString:myLinkID]];
                //(2)remove
                if(1==[[name_dic objectForKey:key] count])
                {
                    [name_dic removeObjectForKey:key];
                    [phone_dic removeObjectForKey:key];
                    [relationName_dic removeObjectForKey:key];
                    [myLinkID_dic removeObjectForKey:key];
                    [kakao_dic removeObjectForKey:key];
                }
                else
                {
                    [[name_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                    [[phone_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                    [[relationName_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                    [[myLinkID_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                    [[kakao_dic objectForKey:key] removeObjectAtIndex:indexPath.row];
                }
                //section index
                NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
                NSArray *sectionTitles_temp = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                for(NSString *str in sectionTitles_temp)
                {
                    [sectionIndexTitles_temp addObject:str];
                    [sectionIndexTitles_temp addObject:@""];
                }
                sectionTitles = nil;
                sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
                [sectionIndexTitles removeAllObjects];
                sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
                [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
            }
            //save in file
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
            MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
            address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
            address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
            address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
            address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
            address2.date_new = [NSArray arrayWithArray:date_new];
            address2.name_new = [NSArray arrayWithArray:name_new];
            address2.phone_new = [NSArray arrayWithArray:phone_new];
            address2.relationName_new = [NSArray arrayWithArray:relationName_new];
            address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
            address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
            address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
            address2.name_hidden = [NSArray arrayWithArray:name_hidden];
            [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
            //badge from new
            if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
            else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
            //title
            int cnt = 0;
            for(NSArray *array in [name_dic allValues])
            {
                cnt += [array count];
            }
            cnt += [date_new count];
            self.navigationItem.title = [NSString stringWithFormat:@"%d명의 지인", cnt];
            [tableView2 reloadData];
            [NSThread detachNewThreadSelector:@selector(hiddenBtnClicked_thread:) toTarget:self withObject:myLinkID];
        }
    }
}
-(void)hiddenBtnClicked_thread:(NSString *)myLinkID
{
    //remove relation in server
    long myLinkID2 = (long)[myLinkID longLongValue];
    NSString *temp = [NSString stringWithFormat:URL3, myid, myLinkID2];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}
- (IBAction)ManageBtnClicked:(id)sender //"숨김관리"를 클릭했을 때
{
    //sort(hidden)
    if([name_hidden count]>1)
    {
        for(int i=0; i<[name_hidden count]-1; i++)
        {
            for(int j=0; j<[name_hidden count]-1; j++)
            {
                NSString *str1 = [name_hidden objectAtIndex:j];
                NSString *str2 = [name_hidden objectAtIndex:j+1];
                if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                {
                    //(1)name
                    NSString *str1_1 = [NSString stringWithString:str1];
                    NSString *str2_1 = [NSString stringWithString:str2];
                    [name_hidden replaceObjectAtIndex:j withObject:str2_1];
                    [name_hidden replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(2)phone
                    str1_1 = [NSString stringWithString:[phone_hidden objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[phone_hidden objectAtIndex:j+1]];
                    [phone_hidden replaceObjectAtIndex:j withObject:str2_1];
                    [phone_hidden replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(2)myLinkID
                    str1_1 = [NSString stringWithString:[myLinkID_hidden objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[myLinkID_hidden objectAtIndex:j+1]];
                    [myLinkID_hidden replaceObjectAtIndex:j withObject:str2_1];
                    [myLinkID_hidden replaceObjectAtIndex:j+1 withObject:str1_1];
                }
            }
        }
    }
    HiddenViewController *hiddenController = (HiddenViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HIDDEN"];
    hiddenController.first = self;
    hiddenController.myid = myid;
    hiddenController.name_hidden = [NSMutableArray arrayWithArray:name_hidden];
    hiddenController.phone_hidden = [NSMutableArray arrayWithArray:phone_hidden];
    hiddenController.myLinkID_hidden = [NSMutableArray arrayWithArray:myLinkID_hidden];
    [self.navigationController pushViewController:hiddenController animated:YES];
}
//From HiddenViewController
-(void)addRelationInFirst:(NSString *)name forPhone:(NSString *)phone forId:(NSString *)myLinkID forLogin:(NSString *)login forIndex:(NSUInteger)curIndex
{
    //Classfication
    NSArray *chosung = [NSArray arrayWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
    NSString *result_key;
    NSInteger unicodeChar = [name characterAtIndex:0];
    if(HANGUL_START_CODE<=unicodeChar && unicodeChar<=HANGUL_END_CODE)
    {
        result_key = [chosung objectAtIndex:(NSInteger)((unicodeChar-HANGUL_START_CODE)/(28*21))];
    }
    else if((ENG_START_CODE1<=unicodeChar && unicodeChar<=ENG_END_CODE1) || (ENG_START_CODE2<=unicodeChar && unicodeChar<=ENG_END_CODE2)) //alphabet
    {
        result_key = [name substringToIndex:1].uppercaseString;
    }
    else
    {
        result_key = @"#";
    }
    if([name_dic objectForKey:result_key])
    {
        //insert
        NSMutableArray *temp1 = [name_dic objectForKey:result_key];
        NSMutableArray *temp2 = [phone_dic objectForKey:result_key];
        NSMutableArray *temp3 = [relationName_dic objectForKey:result_key];
        NSMutableArray *temp4 = [myLinkID_dic objectForKey:result_key];
        NSMutableArray *temp5 = [kakao_dic objectForKey:result_key];
        [temp1 addObject:[NSString stringWithString:name]];
        [temp2 addObject:[NSString stringWithString:phone]];
        [temp3 addObject:[NSString stringWithString:name]];
        [temp4 addObject:[NSString stringWithString:myLinkID]];
        [temp5 addObject:[NSString stringWithString:login]];
        //sort
        for(int i=0; i<[temp1 count]-1; i++)
        {
            for(int j=0; j<[temp1 count]-1; j++)
            {
                NSString *str1 = [temp1 objectAtIndex:j];
                NSString *str2 = [temp1 objectAtIndex:j+1];
                if(1==[str1 localizedCaseInsensitiveCompare:str2]) //replace
                {
                    //(1)name
                    NSString *str1_1 = [NSString stringWithString:str1];
                    NSString *str2_1 = [NSString stringWithString:str2];
                    [temp1 replaceObjectAtIndex:j withObject:str2_1];
                    [temp1 replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(2)phone
                    str1_1 = [NSString stringWithString:[temp2 objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[temp2 objectAtIndex:j+1]];
                    [temp2 replaceObjectAtIndex:j withObject:str2_1];
                    [temp2 replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(3)relationName
                    str1_1 = [NSString stringWithString:[temp3 objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[temp3 objectAtIndex:j+1]];
                    [temp3 replaceObjectAtIndex:j withObject:str2_1];
                    [temp3 replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(4)myLinkID
                    str1_1 = [NSString stringWithString:[temp4 objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[temp4 objectAtIndex:j+1]];
                    [temp4 replaceObjectAtIndex:j withObject:str2_1];
                    [temp4 replaceObjectAtIndex:j+1 withObject:str1_1];
                    //(5)kakao
                    str1_1 = [NSString stringWithString:[temp5 objectAtIndex:j]];
                    str2_1 = [NSString stringWithString:[temp5 objectAtIndex:j+1]];
                    [temp5 replaceObjectAtIndex:j withObject:str2_1];
                    [temp5 replaceObjectAtIndex:j+1 withObject:str1_1];
                }
            }
        }
        [name_dic setObject:temp1 forKey:result_key];
        [phone_dic setObject:temp2 forKey:result_key];
        [relationName_dic setObject:temp3 forKey:result_key];
        [myLinkID_dic setObject:temp4 forKey:result_key];
        [kakao_dic setObject:temp5 forKey:result_key];
    }
    else
    {
        [name_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:name]] forKey:result_key];
        [phone_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:phone]] forKey:result_key];
        [relationName_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:name]] forKey:result_key];
        [myLinkID_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:myLinkID]] forKey:result_key];
        [kakao_dic setObject:[NSMutableArray arrayWithObject:[NSString stringWithString:login]] forKey:result_key];
        //section title
        NSMutableArray *sectionIndexTitles_temp = [NSMutableArray array];
        NSArray *sectionTitles_temp = [[name_dic allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for(NSString *str in sectionTitles_temp)
        {
            [sectionIndexTitles_temp addObject:str];
            [sectionIndexTitles_temp addObject:@""];
        }
        sectionTitles = nil;
        sectionTitles = [NSArray arrayWithArray:sectionTitles_temp];
        [sectionIndexTitles removeAllObjects];
        sectionIndexTitles = [NSMutableArray arrayWithArray:sectionIndexTitles_temp];
        [self.tableView performSelectorOnMainThread:@selector(reloadSectionIndexTitles) withObject:nil waitUntilDone:YES];
    }
    //delete in hidden
    [name_hidden removeObjectAtIndex:curIndex];
    [phone_hidden removeObjectAtIndex:curIndex];
    [myLinkID_hidden removeObjectAtIndex:curIndex];
    //reload table
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK];
    MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
    address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
    address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
    address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
    address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
    address2.date_new = [NSArray arrayWithArray:date_new];
    address2.name_new = [NSArray arrayWithArray:name_new];
    address2.phone_new = [NSArray arrayWithArray:phone_new];
    address2.relationName_new = [NSArray arrayWithArray:relationName_new];
    address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
    address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
    address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
    address2.name_hidden = [NSArray arrayWithArray:name_hidden];
    [NSKeyedArchiver archiveRootObject:address2 toFile:filePath];
    ABAddressBookRevert(addressBookRef); //refresh addressBook
    //badge from new
    if([date_new count]>0) [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",(int)[date_new count]];
    else [[[tabbar viewControllers] objectAtIndex:0] tabBarItem].badgeValue = nil;
}















//searchBar
/*
//iOS8-
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}
*/
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController2
{
    [self filterContentForSearchText:searchController2.searchBar.text scope:[[searchController2.searchBar scopeButtonTitles] objectAtIndex:[searchController2.searchBar selectedScopeButtonIndex]]];
    [self.tableView reloadData];
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [searchResults_keys removeAllObjects];
    [searchResultDic_key removeAllObjects];
    [searchResultDic_num removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    //new
    if([date_new count]>0)
    {
        NSArray *array_new1 = [name_new filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array_new1)
        {
            for(int i=0; i<[name_new count]; i++)
            {
                if([str isEqualToString:[name_new objectAtIndex:i]])
                {
                    NSString *dic_key = [myLinkID_new objectAtIndex:i];
                    [searchResultDic_key setObject:@"new" forKey:dic_key];
                    [searchResultDic_num setObject:[NSString stringWithFormat:@"%d",i] forKey:dic_key];
                }
            }
        }
        NSArray *array_new2 = [relationName_new filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array_new2)
        {
            for(int i=0; i<[relationName_new count]; i++)
            {
                if([str isEqualToString:[relationName_new objectAtIndex:i]])
                {
                    NSString *dic_key = [myLinkID_new objectAtIndex:i];
                    [searchResultDic_key setObject:@"new" forKey:dic_key];
                    [searchResultDic_num setObject:[NSString stringWithFormat:@"%d",i] forKey:dic_key];
                }
            }
        }
        NSArray *array_new3 = [phone_new filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array_new3)
        {
            for(int i=0; i<[phone_new count]; i++)
            {
                if([str isEqualToString:[phone_new objectAtIndex:i]])
                {
                    NSString *dic_key = [myLinkID_new objectAtIndex:i];
                    [searchResultDic_key setObject:@"new" forKey:dic_key];
                    [searchResultDic_num setObject:[NSString stringWithFormat:@"%d",i] forKey:dic_key];
                }
            }
        }
    }
    //
    for(int i=0; i<[sectionTitles count]; i++)
    {
        NSString *key = [sectionTitles objectAtIndex:i];
        //(1)
        NSArray *array = [name_dic objectForKey:key];
        NSArray *array2 = [array filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array2)
        {
            for(int j=0; j<[array count]; j++)
            {
                if([str isEqualToString:[array objectAtIndex:j]])
                {
                    NSString *num = [NSString stringWithFormat:@"%d",j];
                    NSString *dic_key = [[myLinkID_dic objectForKey:key] objectAtIndex:j];
                    [searchResultDic_key setObject:key forKey:dic_key];
                    [searchResultDic_num setObject:num forKey:dic_key];
                }
            }
        }
        //(2)
        NSArray *array3 = [relationName_dic objectForKey:key];
        NSArray *array4 = [array3 filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array4)
        {
            for(int j=0; j<[array3 count]; j++)
            {
                if([str isEqualToString:[array3 objectAtIndex:j]])
                {
                    NSString *num = [NSString stringWithFormat:@"%d",j];
                    NSString *dic_key = [[myLinkID_dic objectForKey:key] objectAtIndex:j];
                    [searchResultDic_key setObject:key forKey:dic_key];
                    [searchResultDic_num setObject:num forKey:dic_key];
                }
            }
        }
        //(3)
        NSArray *array5 = [phone_dic objectForKey:key];
        NSArray *array6 = [array5 filteredArrayUsingPredicate:resultPredicate];
        for(NSString *str in array6)
        {
            for(int j=0; j<[array5 count]; j++)
            {
                if([str isEqualToString:[array5 objectAtIndex:j]])
                {
                    NSString *num = [NSString stringWithFormat:@"%d",j];
                    NSString *dic_key = [[myLinkID_dic objectForKey:key] objectAtIndex:j];
                    [searchResultDic_key setObject:key forKey:dic_key];
                    [searchResultDic_num setObject:num forKey:dic_key];
                }
            }
        }
    }
    [searchResults_keys addObjectsFromArray:[searchResultDic_key allKeys]];
}
/*
//iOS8-
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    isSearching = YES;
}
-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    isSearching = NO;
    indexPath_textField = nil;
    [self.tableView reloadData];
}
*/
/*
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    isSearching = NO;
    indexPath_textField = nil;
    [self.tableView reloadData];
}
*/
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //isSearching = NO;
    indexPath_textField = nil;
    [self.tableView reloadData];
}









//textField
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //isTextField = YES;
    curText = [NSString stringWithString:textField.text];
    if(searchController.active)
    {
        CGPoint point = [textField.superview convertPoint:textField.center toView:(UITableView *)searchController.searchResultsController];
        //indexPath_textField = [(UITableView *)searchController.searchResultsController indexPathForRowAtPoint:point];
        NSLog(@"%f", searchController.searchBar.frame.size.height);
        indexPath_textField = [NSIndexPath indexPathForRow:(int)((point.y-searchController.searchBar.frame.size.height)/CELL_HEIGHT) inSection:0];
    }
    else
    {
        CGPoint point = [textField.superview convertPoint:textField.center toView:self.tableView];
        indexPath_textField = [self.tableView indexPathForRowAtPoint:point];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //isTextField = NO;
    if(indexPath_textField)
    {
        if(searchController.active)
        {
            if([curText isEqualToString:textField.text]) return;
            //(1)data update
            NSString *mykey = [searchResults_keys objectAtIndex:indexPath_textField.row];
            NSString *key = [searchResultDic_key objectForKey:mykey];
            NSString *num = [searchResultDic_num objectForKey:mykey];
            int index = [num intValue];
            if([key isEqualToString:@"new"]) //new
            {
                [relationName_new replaceObjectAtIndex:index withObject:textField.text];
            }
            else
            {
                NSMutableArray *temp = [relationName_dic objectForKey:key];
                [temp replaceObjectAtIndex:index withObject:textField.text];
                [relationName_dic setObject:temp forKey:key];
            }
            //(2)server upload
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:key, num, textField.text, nil] forKeys:[NSArray arrayWithObjects:@"first", @"second", @"third", nil]];
            [NSThread detachNewThreadSelector:@selector(relationNameUpload2:) toTarget:self withObject:dic];
        }
        else
        {
            if([curText isEqualToString:textField.text]) return;
            if([date_new count]>0)
            {
                if(1==indexPath_textField.section)  //new
                {
                    //(1)data update
                    [relationName_new replaceObjectAtIndex:indexPath_textField.row withObject:textField.text];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath_textField] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                {
                    //(1)data update
                    NSString *key = [sectionTitles objectAtIndex:indexPath_textField.section-2];
                    NSMutableArray *temp = [relationName_dic objectForKey:key];
                    [temp replaceObjectAtIndex:indexPath_textField.row withObject:textField.text];
                    [relationName_dic setObject:temp forKey:key];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath_textField] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            else
            {
                //(1)data update
                NSString *key = [sectionTitles objectAtIndex:indexPath_textField.section-1];
                NSMutableArray *temp = [relationName_dic objectForKey:key];
                [temp replaceObjectAtIndex:indexPath_textField.row withObject:textField.text];
                [relationName_dic setObject:temp forKey:key];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath_textField] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            //(2)server upload
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:indexPath_textField, textField.text, nil] forKeys:[NSArray arrayWithObjects:@"first", @"second", nil]];
            [NSThread detachNewThreadSelector:@selector(relationNameUpload:) toTarget:self withObject:dic];
        }
    }
}
-(void)relationNameUpload2:(NSDictionary *)dic
{
    MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
    address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
    address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
    address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
    address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
    address2.date_new = [NSArray arrayWithArray:date_new];
    address2.name_new = [NSArray arrayWithArray:name_new];
    address2.phone_new = [NSArray arrayWithArray:phone_new];
    address2.relationName_new = [NSArray arrayWithArray:relationName_new];
    address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
    address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
    address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
    address2.name_hidden = [NSArray arrayWithArray:name_hidden];
    [NSKeyedArchiver archiveRootObject:address2 toFile:[NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK]];
    //
    NSString *key = [dic objectForKey:@"first"];
    NSString *num = [dic objectForKey:@"second"];
    NSString *text = [dic objectForKey:@"third"];
    long myLinkID;
    if([key isEqualToString:@"new"]) //new
    {
        myLinkID = (long)[[myLinkID_new objectAtIndex:[num intValue]] longLongValue];
    }
    else
    {
        myLinkID = (long)[[[myLinkID_dic objectForKey:key] objectAtIndex:[num intValue]] longLongValue];
    }
    NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:text]];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}
-(void)relationNameUpload:(NSDictionary *)dic
{
    MyLinkAddressBook *address2 = [[MyLinkAddressBook alloc] init];
    address2.myLinkID_dic = [NSDictionary dictionaryWithDictionary:myLinkID_dic];
    address2.phone_dic = [NSDictionary dictionaryWithDictionary:phone_dic];
    address2.name_dic = [NSDictionary dictionaryWithDictionary:name_dic];
    address2.relationName_dic = [NSDictionary dictionaryWithDictionary:relationName_dic];
    address2.date_new = [NSArray arrayWithArray:date_new];
    address2.name_new = [NSArray arrayWithArray:name_new];
    address2.phone_new = [NSArray arrayWithArray:phone_new];
    address2.relationName_new = [NSArray arrayWithArray:relationName_new];
    address2.myLinkID_new = [NSArray arrayWithArray:myLinkID_new];
    address2.myLinkID_hidden = [NSArray arrayWithArray:myLinkID_hidden];
    address2.phone_hidden =  [NSArray arrayWithArray:phone_hidden];
    address2.name_hidden = [NSArray arrayWithArray:name_hidden];
    [NSKeyedArchiver archiveRootObject:address2 toFile:[NSHomeDirectory() stringByAppendingPathComponent:ADDRESSBOOK]];
    //
    NSIndexPath *indexPath = [dic objectForKey:@"first"];
    NSString *text = [dic objectForKey:@"second"];
    long myLinkID;
    if([date_new count]>0)
    {
        if(1==indexPath.section)
        {
            myLinkID = (long)[[myLinkID_new objectAtIndex:indexPath.row] longLongValue];
        }
        else
        {
            myLinkID = (long)[[[myLinkID_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row] longLongValue];
        }
    }
    else
    {
        myLinkID = (long)[[[myLinkID_dic objectForKey:[sectionTitles objectAtIndex:indexPath.section-1]] objectAtIndex:indexPath.row] longLongValue];
    }
    NSString *temp = [NSString stringWithFormat:URL2, myid, myLinkID, [self stringByReplacingforJSON:text]];
    [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:temp]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}












/*
//keyboard
-(void)keyboardWillShow:(NSNotification *)noti
{
    if(!isSearching && isTextField)
    {
        CGRect rect = [[[noti userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        UIEdgeInsets insets = UIEdgeInsetsMake(curInsets.top, curInsets.left, curInsets.bottom+rect.size.height, curInsets.right);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }
}
-(void)keyboardWillHide:(NSNotification *)noti
{
    //[self.tableView reloadSectionIndexTitles];
    if(!isSearching && isTextField)
    {
        self.tableView.contentInset = curInsets;
        self.tableView.scrollIndicatorInsets = curInsets;
    }
}
*/







//progress
-(void)performProgress:(NSNumber *)number
{
    progress.progress = [number floatValue];
}
-(void)dismissAlertMain
{
    [alert_main dismissWithClickedButtonIndex:0 animated:YES];
}
















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

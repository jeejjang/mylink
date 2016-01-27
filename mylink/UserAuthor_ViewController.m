//
//  UserAuthor_ViewController.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 8. 25..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import "UserAuthor_ViewController.h"

@interface UserAuthor_ViewController ()

@end

@implementation UserAuthor_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    textView_author.text = @"\n\n1. 마이링크는 사용자의 동의를 통해 주소록에 등록된 전화번호와 이름에만 합법적으로 접근하며, 이 외에 어떠한 정보에도 접근하지 않습니다.\n\n2. 관계검색은 단지 전화번호만 이용하며, 내 주소록에 등록된 어떠한 전화번호도 타인이 알 수 없습니다.\n\n3. 관계정보는 주소록의 이름을 사용하며, 이 관계이름은 앱 안에서 항상 수정 및 삭제가 가능합니다.\n\n4. 공개를 원하지 않는 관계는 숨김기능을 통해 완전히 감출 수 있습니다.\n\n5. 마이링크를 통해 카카오에 로그인한 상태에서만 다른사람에게 카카오 정보가 공개됩니다.\n- 카카오톡 닉네임, 프로필 사진, 카카오 스토리 닉네임, 생일, 프로필사진, 배경사진, 가장 최근의 공개글";
}

- (void)didReceiveMemoryWarning {
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

- (IBAction)btnCloseClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

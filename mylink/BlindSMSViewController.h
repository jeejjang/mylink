//
//  BlindSMSViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 1. 2..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "FirstViewController.h"

@interface BlindSMSViewController : UIViewController<HPGrowingTextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UIActivityIndicatorView *indicator;
    
    //sender
    IBOutlet UITextField *textView_sender;
    //receiver
    IBOutlet UITextField *textView_receiver;
    //->
    IBOutlet UIView *view_receiver;
    IBOutlet UIView *view_receiver2;
    IBOutlet UITextField *textField_receiver;
    IBOutlet UITableView *tableView_receiver;
    
    //history
    IBOutlet UITableView *tableView_history;
    //UIImage *img_arrow;
    NSMutableArray *sends_history_array;
    NSMutableArray *names_history_array; // - texts_array
    NSMutableArray *dates_history_array;
    NSMutableArray *texts_history_array; // - textView.text
    int index_history; //항목 삭제 인덱스(매개변수)
    
    //예약설정
    IBOutlet UILabel *label_time;
    //
    IBOutlet UILabel *label_date;
    NSString *str_date; //예약 날짜
    NSString *str_time; //예약 시각
    IBOutlet UIBarButtonItem *btn_del;
    IBOutlet UIView *view_date;
    IBOutlet UIView *view_date2;
    IBOutlet UIDatePicker *picker_date;
    
    //container view(SMS)
    UIView *containerView;
    //NSString *smsType;
    //UILabel *label_type;
    //UILabel *label_percent;
    HPGrowingTextView *textView;
    UIButton *inputBtn;
    //매개변수
    NSString *str_send1;
    NSString *str_send2;
    NSString *str_send3;
    IBOutlet UIView *view_touchScreen;  //키보드를 내릴 때
    
    //node
    int nodes;
    IBOutlet UILabel *label_node;   //노드 소모량

    
}

@property FirstViewController *first;
@property int flag; //0:관계 중에서 블라인드 문자를 보내는 경우 / 1:검색 결과로 나온 사람들에게 문자를 보내는 경우 / 2:임의의 사람에게 보내는 경우(더보기)
//flag가 0 또는 1인 경우 ->
@property NSString *text_receiver; //textView_receiver에 처음 전달되는 텍스트
@property NSString *phone_receiver; //실제 번호

//sender
//- (IBAction)btnMyPhoneClicked:(id)sender;

//receiver
@property UITableView *tableView_receiver;
@property NSMutableArray *texts_array; //테이블에서 보여지는 이름 배열
@property NSMutableArray *phones_array; //실제 전화번호 배열
- (IBAction)receiverCloseClicked:(id)sender;
- (IBAction)receiverLoadClicked:(id)sender;
- (IBAction)receiverSaveClicked:(id)sender;
- (IBAction)receiverAddClicked:(id)sender;
- (IBAction)receiverAddressClicked:(id)sender;

//예약설정
- (IBAction)reserveClicked:(id)sender;  //'예약설정' 버튼
- (IBAction)dateCancelClicked:(id)sender;
- (IBAction)dateSaveClicked:(id)sender;
- (IBAction)dateDeleteClicked:(id)sender;

//'취소' 버튼
- (IBAction)cancelClicked:(id)sender;


@end

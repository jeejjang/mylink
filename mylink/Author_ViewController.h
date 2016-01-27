//
//  Author_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface Author_ViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UIView *view_screen;
    
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UITextField *textField_phone;
    IBOutlet UITextView *textView_author;
    UIToolbar *toolBar; //accessory
    
    NSString *phone_num;    //인증번호
    NSString *phone; //인증받는 전화번호
    long myid;
}



@end

//
//  UserInfoImgZoom_ViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 10. 2..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoImgZoom_ViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView_zoom;
    UIImageView *imageView_zoom;
    IBOutlet UIButton *button_zoom;
}
- (IBAction)btnCancelClicked:(id)sender;

@property UIImage *image;

@end

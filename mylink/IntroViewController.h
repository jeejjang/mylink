//
//  IntroViewController.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 10. 1..
//  Copyright © 2015년 ZANDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *indicator;
}


@property NSString *str_url;

- (IBAction)btnCloseClicked:(id)sender;


@end

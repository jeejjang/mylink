//
//  ImageDownloader2.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 5. 11..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageDownloader2 <NSObject>

-(void)didFinishedDownload:(UIImage *)image at:(NSIndexPath *)indexPath forId:(NSString *)str_id forI:(int)indexI forJ:(int)indexJ;

@end

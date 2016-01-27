//
//  ImageDownloader.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageDownloader <NSObject>

-(void)didFinishedDownload:(UIImage *)image at:(NSIndexPath *)indexPath forKey:(NSNumber *)num;

@end

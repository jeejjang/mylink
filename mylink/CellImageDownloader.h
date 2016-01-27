//
//  CellImageDownloader.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageDownloader.h"

@interface CellImageDownloader : NSOperation
{
    NSString *urlStr;
    NSIndexPath *indexPath;
    NSNumber *num;
    id<ImageDownloader> delegate2;
}

@property NSString *urlStr;
@property NSIndexPath *indexPath;
@property NSNumber *num;
@property id<ImageDownloader> delegate2;

@end

//
//  CellImageDownloader2.h
//  mylink
//
//  Created by JeongMin Ji on 2015. 5. 11..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageDownloader2.h"

@interface CellImageDownloader2 : NSOperation
{
    //NSString *urlStr;
    NSIndexPath *indexPath;
    NSString *str_id;
    int indexI;
    int indexJ;
    id<ImageDownloader2> delegate2;
}

//@property NSString *urlStr;
@property NSIndexPath *indexPath;
@property NSString *str_id;
@property int indexI;
@property int indexJ;
@property id<ImageDownloader2> delegate2;

@end

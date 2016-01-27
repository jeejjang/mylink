//
//  CellImageDownloader.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "CellImageDownloader.h"

@implementation CellImageDownloader
@synthesize urlStr, indexPath, num, delegate2;

-(void)main
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
    [delegate2 didFinishedDownload:image at:indexPath forKey:num];
}

@end

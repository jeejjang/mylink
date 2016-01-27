//
//  CellImageDownloader2.m
//  mylink
//
//  Created by JeongMin Ji on 2015. 5. 11..
//  Copyright (c) 2015년 ZANDA. All rights reserved.
//

#define URL1 @"http://jeejjang.cafe24.com/link/kakao_img_thumb.jsp?id=%@"

#import "CellImageDownloader2.h"

@implementation CellImageDownloader2
@synthesize indexPath, str_id, indexI, indexJ, delegate2;

-(void)main
{
    UIImage *image = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:URL1, str_id]]] options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:NULL];
    if(result)
    {
        if([[result objectForKey:@"result"] isEqualToString:@"0"])
        {
            image = [UIImage imageNamed:@"empty2"];
        }
        else if([[result objectForKey:@"result"] isEqualToString:@"1"])
        {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"url"]]]];
            if(!image)
            {
                image = [UIImage imageNamed:@"empty2"];
            }
        }
    }
    [delegate2 didFinishedDownload:image at:indexPath forId:str_id forI:indexI forJ:indexJ];
}

@end
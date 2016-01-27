//
//  MyLinkAddressBook.h
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyLinkAddressBook : NSObject<NSCoding>

@property NSDictionary *myLinkID_dic;
@property NSDictionary *phone_dic;
@property NSDictionary *name_dic;
@property NSDictionary *relationName_dic;

//"새로 추가된 관계"
@property NSArray *date_new;   
@property NSArray *name_new;
@property NSArray *phone_new;
@property NSArray *relationName_new;
@property NSArray *myLinkID_new;

@property NSArray *myLinkID_hidden;
@property NSArray *phone_hidden;
@property NSArray *name_hidden;

@end

//
//  MyLinkAddressBook.m
//  mylink
//
//  Created by JeongMin Ji on 2014. 9. 26..
//  Copyright (c) 2014년 ZANDA. All rights reserved.
//

#import "MyLinkAddressBook.h"

@implementation MyLinkAddressBook
@synthesize myLinkID_dic, phone_dic, name_dic, relationName_dic, date_new, name_new, phone_new, relationName_new, myLinkID_new, myLinkID_hidden, phone_hidden, name_hidden;

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:myLinkID_dic forKey:@"myLinkID"];
    [aCoder encodeObject:phone_dic forKey:@"phone"];
    [aCoder encodeObject:name_dic forKey:@"name"];
    [aCoder encodeObject:relationName_dic forKey:@"relation"];
    
    [aCoder encodeObject:date_new forKey:@"dateNew"];
    [aCoder encodeObject:name_new forKey:@"nameNew"];
    [aCoder encodeObject:phone_new forKey:@"phoneNew"];
    [aCoder encodeObject:relationName_new forKey:@"relationNew"];
    [aCoder encodeObject:myLinkID_new forKey:@"myLinkIDNew"];
    
    [aCoder encodeObject:myLinkID_hidden forKey:@"myLinkIDHidden"];
    [aCoder encodeObject:phone_hidden forKey:@"phoneHidden"];
    [aCoder encodeObject:name_hidden forKey:@"nameHidden"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.myLinkID_dic = [aDecoder decodeObjectForKey:@"myLinkID"];
        self.phone_dic = [aDecoder decodeObjectForKey:@"phone"];
        self.name_dic = [aDecoder decodeObjectForKey:@"name"];
        self.relationName_dic = [aDecoder decodeObjectForKey:@"relation"];
        
        self.date_new = [aDecoder decodeObjectForKey:@"dateNew"];
        self.name_new = [aDecoder decodeObjectForKey:@"nameNew"];
        self.phone_new = [aDecoder decodeObjectForKey:@"phoneNew"];
        self.relationName_new = [aDecoder decodeObjectForKey:@"relationNew"];
        self.myLinkID_new = [aDecoder decodeObjectForKey:@"myLinkIDNew"];
        
        self.myLinkID_hidden = [aDecoder decodeObjectForKey:@"myLinkIDHidden"];
        self.phone_hidden = [aDecoder decodeObjectForKey:@"phoneHidden"];
        self.name_hidden = [aDecoder decodeObjectForKey:@"nameHidden"];
    }
    return self;
}

@end

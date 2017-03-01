//
//  Contacts.m
//  TwoDimensionCode
//
//  Created by xp on 2016/12/2.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import "Contacts.h"

@implementation Contacts

-(instancetype)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email{
    if (self) {
        self.conName = name;
        self.conPhone = phone;
        self.conEmail = email;
    }
    return self;
}

@end

//
//  GetAndAddContacts.h
//  TwoDimensionCode
//
//  Created by xp on 2016/11/23.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#endif

#define kName @"name"
#define kPhoneNum @"phoneNum"


@interface GetAndAddContacts : NSObject {
    NSMutableArray *allContactsArr;
}

+ (instancetype)sharedContacts;

-(NSArray *)getAllContacts;

-(BOOL)AddContactsToMailList:(id)aContacts;

@end

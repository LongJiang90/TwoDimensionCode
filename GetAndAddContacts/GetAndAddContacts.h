//
//  GetAndAddContacts.h
//  TwoDimensionCode
//
//  Created by xp on 2016/11/23.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contacts.h"

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
/**< 获取所有的通讯录联系人 */
-(NSArray *)getAllContacts;
/**< 新增一个/多个联系人到通讯录中 */
-(void)addContactsToMailList:(NSArray *)contactsArr;

@end

//
//  GetAndAddContacts.m
//  TwoDimensionCode
//
//  Created by xp on 2016/11/23.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import "GetAndAddContacts.h"

@implementation GetAndAddContacts

+ (instancetype)sharedContacts {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(NSArray *)getAllContacts{
    if ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_x_Max)) {
        [self fetchAddressBookBeforeIOS10];
    }else{
        [self fetchAddressBookBeforeIOS9];
    }
    return allContactsArr;;
}

- (void)fetchAddressBookBeforeIOS10 {
    //创建CNContactStore对象,用与获取和保存通讯录信息
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {//首次访问通讯录会调用
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) return;
            if (granted) {//允许
                NSLog(@"授权访问通讯录");
                allContactsArr = [self fetchContactWithContactStore:contactStore];//访问通讯录
            }else{//拒绝
                NSLog(@"拒绝访问通讯录");//访问通讯录
            }  
        }];  
    }else{  
        allContactsArr = [self fetchContactWithContactStore:contactStore];//访问通讯录
    }
}

-(NSMutableArray *)fetchContactWithContactStore:(CNContactStore *)contactStore{
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {//有权限访问
        NSError *error = nil;
        //创建数组,必须遵守CNKeyDescriptor协议,放入相应的字符串常量来获取对应的联系人信息
        NSArray <id<CNKeyDescriptor>> *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        //创建获取联系人的请求
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        //遍历查询
        NSMutableArray *contacts = [NSMutableArray array];
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            if (!error) {
                NSString *familyName = contact.familyName;
                NSString *givenName = contact.givenName;
                NSString *phoneNumber = ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue;
                
                NSLog(@"familyName = %@", contact.familyName);//姓
                NSLog(@"givenName = %@", contact.givenName);//名字
                NSLog(@"phoneNumber = %@", ((CNPhoneNumber *)(contact.phoneNumbers.lastObject.value)).stringValue);//电话
                [contacts addObject:@{kName: [familyName stringByAppendingString:givenName], kPhoneNum: phoneNumber!=nil?phoneNumber:@""}];
            }else{  
                NSLog(@"error:%@", error.localizedDescription);  
            }  
        }];
        return contacts;
    }else{//无权限访问  
        NSLog(@"拒绝访问通讯录");
        return nil;
    }
}

- (void)fetchAddressBookBeforeIOS9{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    //用户授权
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {//首次访问通讯录
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (!error) {
                if (granted) {//允许
                    NSArray *contacts = [self fetchContactWithAddressBook:addressBook];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"contacts:%@", contacts);
                    });
                    allContactsArr = contacts.mutableCopy;
                }else{//拒绝
                }
            }else{
                NSLog(@"错误!");
            }
        });
    }else{//非首次访问通讯录
        NSArray *contacts = [self fetchContactWithAddressBook:addressBook];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"contacts:%@", contacts);
        });
        allContactsArr = contacts.mutableCopy;
    }
}

- (NSMutableArray *)fetchContactWithAddressBook:(ABAddressBookRef)addressBook{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {////有权限访问
        //获取联系人数组
        NSArray *array = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *contacts = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            //获取联系人
            ABRecordRef people = CFArrayGetValueAtIndex((__bridge ABRecordRef)array, i);
            //获取联系人详细信息,如:姓名,电话,住址等信息
            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(people, kABPersonLastNameProperty);
            ABMutableMultiValueRef *phoneNumRef = ABRecordCopyValue(people, kABPersonPhoneProperty);
            NSString *phoneNumber =  ((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumRef)).lastObject;
            [contacts addObject:@{kName: [firstName stringByAppendingString:lastName], kPhoneNum: phoneNumber!=nil?phoneNumber:@""}];
        }
        return contacts;
    }else{//无权限访问
        NSLog(@"无权限访问通讯录");
        return nil;
    }
}



@end

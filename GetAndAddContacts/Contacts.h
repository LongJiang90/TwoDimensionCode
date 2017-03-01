//
//  Contacts.h
//  TwoDimensionCode
//
//  Created by xp on 2016/12/2.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contacts : NSObject

@property (nonatomic,copy) NSString *conName;/**< 联系人姓名 */
@property (nonatomic,copy) NSString *conPhone;/**< 联系人电话 */
@property (nonatomic,copy) NSString *conEmail;/**< 联系人邮箱 */

-(instancetype)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email;

@end

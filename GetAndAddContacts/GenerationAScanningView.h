//
//  GenerationAScanningView.h
//  TwoDimensionCode
//
//  Created by xp on 2016/11/24.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^SucBlock)(NSString *sucStr);

@interface GenerationAScanningView : UIView

@property (nonatomic,strong) UIColor *backgroundColor;/**< 生成二维码背景颜色 */
@property (nonatomic,strong) UIColor *frontColor;/**< 生成二维码填充颜色 */
@property (nonatomic,strong) UIImage *centerImage;/**< 生成二维码中间小图片 */

/**
 * 直接开启摄像头扫描二维码
 *
 *
 *
 *
 *
 */
-(void)scanningCodeBySucBlock:(SucBlock) sucBlock;

/**
 * 从图片中扫描二维码
 *
 *
 *
 *
 *
 */
+(NSString *)scanningCodeByImg:(UIImage *)image;

/**
 * 生成二维码
 *
 *
 *
 *
 *
 */
-(UIImage *)generationCodeByStr:(NSString *)str size:(CGSize)size;



@end

//
//  GenerationAScanningView.m
//  TwoDimensionCode
//
//  Created by xp on 2016/11/24.
//  Copyright © 2016年 com.yunwangnet. All rights reserved.
//

#import "GenerationAScanningView.h"

@interface GenerationAScanningView ()<AVCaptureMetadataOutputObjectsDelegate>{
    BOOL flashOpen;
    SucBlock _sucBlock;
    UIButton *leftBtn;
    UIButton *rightBtn;
}
@property (nonatomic,strong) AVCaptureSession *session;/**< <#注释#> */

@end

@implementation GenerationAScanningView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        if (leftBtn == nil && rightBtn == nil) {
            [self setUpSession];
            [self setUI];
        }
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setUI{
    leftBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [leftBtn setTitle:@"X" forState:(UIControlStateNormal)];
    [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    
    leftBtn.frame = CGRectMake(15, 25, 60, 40);
    [self addSubview:leftBtn];
    
    rightBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [rightBtn setTitle:@"开/关时光灯" forState:(UIControlStateNormal)];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    
    rightBtn.frame = CGRectMake(self.frame.size.width-110, 25, 100, 40);
    [self addSubview:rightBtn];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)scanningCodeBySucBlock:(SucBlock) sucBlock{
    _sucBlock = sucBlock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.frame = self.layer.bounds;
        [self.layer insertSublayer:layer atIndex:0];
    });
    
    [self.session startRunning];
}
-(void)setUpSession{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input)
    {
        return;
    }
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫描区域的比例
    CGFloat width = 300 / CGRectGetHeight(self.frame);
    CGFloat height = 300 / CGRectGetWidth(self.frame);
    output.rectOfInterest = CGRectMake((1 - width) / 2, (1- height) / 2, width, height);
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:input];
    [session addOutput:output];
    
    //设置扫码支持的编码格式(这里设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode128Code];
    self.session = session;
    
    //加一个蒙层
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [self addSubview:maskView];
    
    //在蒙层上面扣一个洞
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(30, 100, CGRectGetWidth(self.frame) - 60, 300) cornerRadius:1] bezierPathByReversingPath]];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    maskLayer.path = maskPath.CGPath;
    
    maskView.layer.mask = maskLayer;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        if (_sucBlock) {
            _sucBlock(metadataObject.stringValue);
        }
    }
}

- (void)leftBtnClick:(UIButton *)sender{
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0.1;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)rightBtnClick:(UIButton *)sender{
    flashOpen = !flashOpen;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        
        if (flashOpen)
        {
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
        }
        else
        {
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
}

+ (NSString *)scanningCodeByImg:(UIImage *)image{
    NSString *str = @"";
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1)
    {
        CIQRCodeFeature *feature = [features firstObject];
        str = feature.messageString;
    }
    return str;
}

- (UIImage *)generationCodeByStr:(NSString *)str size:(CGSize)size{
    UIImage *image = [self createQRImageWithString:str size:size];
    return image;
}

/** 生成指定大小的黑白二维码 */
- (UIImage *)createQRImageWithString:(NSString *)string size:(CGSize)size
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //    NSLog(@"%@",qrFilter.inputKeys);
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    //放大并绘制二维码 (上面生成的二维码很小，需要放大)
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    //翻转一下图片 不然生成的QRCode就是上下颠倒的
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    if (self.backgroundColor != nil || self.frontColor != nil) {
        codeImage = [self changeColorForQRImage:codeImage backColor:self.backgroundColor?self.backgroundColor:[UIColor whiteColor] frontColor:self.frontColor?self.frontColor:[UIColor blackColor]];
    }
    if (self.centerImage != nil) {
        codeImage = [self addSmallImageForQRImage:codeImage andsmallImg:self.centerImage];
    }
    
    return codeImage;
}

/** 为二维码改变颜色 */
- (UIImage *)changeColorForQRImage:(UIImage *)image backColor:(UIColor *)backColor frontColor:(UIColor *)frontColor
{
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",[CIImage imageWithCGImage:image.CGImage],
                             @"inputColor0",[CIColor colorWithCGColor:frontColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:backColor.CGColor],
                             nil];
    
    return [UIImage imageWithCIImage:colorFilter.outputImage];
}

/** 在二维码中心加一个小图 */
- (UIImage *)addSmallImageForQRImage:(UIImage *)qrImage andsmallImg:(UIImage *)smallImg
{
    UIGraphicsBeginImageContext(qrImage.size);
    [qrImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
    CGFloat imageW = qrImage.size.width/5;
    CGFloat imageX = (qrImage.size.width - imageW) * 0.5;
    CGFloat imgaeY = (qrImage.size.height - imageW) * 0.5;
    [smallImg drawInRect:CGRectMake(imageX, imgaeY, imageW, imageW)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end

//
//  RB_QRScan.h
//  Kiwi
//
//  Created by Ray on 2018/5/31.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@class RACSignal;

@interface RB_QRScan : NSObject

+ (RB_QRScan *)scan;

- (void)getReady:(void (^)(AVCaptureVideoPreviewLayer *layer))layer;

/** 默认brightness为 -1 时，开启闪光灯 */
@property (nonatomic, strong)RACSignal *flashOn;


/** 重置 session */
@property (nonatomic, strong)RACSignal *sessionStatus;

@end
//
//  ReactiveViewController.m
//  RBToolKit_Example
//
//  Created by Ray on 2018/5/30.
//  Copyright © 2018年 wzc5670594. All rights reserved.
//

#import "ReactiveViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

@interface ReactiveViewController ()

@end

@implementation ReactiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self sequence];
    
//    [self racCommand];
    
//    [self racConcat];
    
    [self racCombiLatest];
    
}

- (void)sequence {
    
        RACSignal *numbers = @[@(0), @(1), @(2)].rac_sequence.signal;
    
        RACSignal *letters1 = @[@"A", @"B", @"C"].rac_sequence.signal;
        RACSignal *letters2 = @[@"X", @"Y", @"Z"].rac_sequence.signal;
        RACSignal *letters3 = @[@"M", @"N"].rac_sequence.signal;
        NSArray *arrayOfSignal = @[letters1, letters2, letters3]; //2
    
        [[[[numbers
            map:^id(NSNumber *n) {
                return arrayOfSignal[n.integerValue];
            }] collect] flattenMap:^RACSignal *(NSArray *arrayOfSignal) {
              //1
              return [RACSignal combineLatest:arrayOfSignal
                                       reduce:^(NSString *first, NSString *second, NSString *third) {
                                           return [NSString stringWithFormat:@"%@-%@-%@", first, second, third];
                                       }];
          }]
         subscribeNext:^(NSString *x) {
             NSLog(@"%@, %@", [x class], x);
         } completed:^{
             NSLog(@"completed");
         }];
}

- (void)racCommand {
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        NSLog(@"创建 command: %@", input);
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendError:[NSError errorWithDomain:@"412" code:3 userInfo:@{}]];
            
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                
                NSLog(@"singal disposable: %@", input);
                
            }];
        }];
    }];
    
    [[command executing] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing : %@", x);
    }];
    
    [[command executionSignals] subscribeNext:^(id  _Nullable x) {
        NSLog(@"executionSignals : %@", x);
    }];
    
    [[command executionSignals].switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest : %@", x);
    }];
    
    [command.errors subscribeError:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
    
    [command execute:@101];
}


- (void)racConcat {
    /**
     * concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
     * concat底层实现:
     * 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
     * 2.didSubscribe中，会先订阅第一个源信号（signalA）
     * 3.会执行第一个源信号（signalA）的didSubscribe
     * 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
     * 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
     * 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
     * 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
     */
    
    RACSignal *a = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"a"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    
    RACSignal *b = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendError:[NSError errorWithDomain:@"b" code:0 userInfo:@{}]];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    RACSignal *c = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"c"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    RACSignal *ccc = [[a concat:b] concat:c];
    
    [ccc subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}


- (void)racCombiLatest {

    RACSignal *a = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"a"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    
    RACSignal *b = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"b"];
//        [subscriber sendError:[NSError errorWithDomain:@"b" code:0 userInfo:@{}]];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    RACSignal *c = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"c"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            ;
        }];
    }];
    
    RACSignal *ccc = [RACSignal combineLatest:@[a, b, c]];
    
    [ccc subscribeNext:^(RACTuple *_Nullable x) {
        
        NSLog(@"%@-%ld", x, x.count);
    } error:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

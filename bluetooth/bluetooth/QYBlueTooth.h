//
//  QYBlueTooth.h
//  bluetooth
//
//  Created by guoqingyang on 16/3/11.
//  Copyright © 2016年 guoqingyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface QYBlueTooth : NSObject
@property(nonatomic,strong)CBPeripheral *peripheral;
+ (QYBlueTooth*)shareBlueTooth;

-(void)start;
-(void)connect:(CBPeripheral*)peripheral;
@end

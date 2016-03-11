//
//  QYBlueTooth.m
//  bluetooth
//
//  Created by guoqingyang on 16/3/11.
//  Copyright © 2016年 guoqingyang. All rights reserved.
//

#import "QYBlueTooth.h"

@interface QYBlueTooth ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
}
@property(nonatomic,strong)NSMutableArray *pers;
@end

@implementation QYBlueTooth

static QYBlueTooth *data;

+ (QYBlueTooth*)shareBlueTooth{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (data==nil) {
            data = [QYBlueTooth new];
        }
    });
    return data;
}

-(void)start{
    self.pers = [NSMutableArray new];
    manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

//设置完蓝牙必走的方法,监测蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *message = [NSString new];
    switch (central.state) {
        case 4:
            message = @"尚未打开蓝牙，请在设置中打开……";
            break;
        case 5:
            message = @"蓝牙已经成功开启，稍后……";
            //扫描所有设备,nil的话为所有设备
            [manager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
    NSLog(@"%@",message);
}
//扫描之后的方法
//发现外围的方法
//peripheral 外围设备
//advertisementData外围设备发出的信号
//RSSI信号强度
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
        if (![self.pers containsObject:peripheral]) {
            [self.pers addObject:peripheral];
            //通知我的设备发现了新设备
        }
  
   }
//连接设备
-(void)connect:(CBPeripheral*)peripheral{
    [manager connectPeripheral:peripheral options:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败");
}
//连接之后调用的方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [manager stopScan];//蓝牙停止扫描
    //扫描所有的服务
    //serviceUUIDs数组扫描什么服务,nil扫描所有服务
    self.peripheral = peripheral;
    self.peripheral.delegate  = self;
    [self.peripheral discoverServices:nil];
}
//找到服务的之后执行的代理方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //扫描到之后会把服务直接添加到外围的服务数组里面
    for (CBService *serive in peripheral.services) {
        if ([serive.UUID.UUIDString isEqualToString:@"FFE0"]) {
            //遍历之后找到了自己想要的服务
            //然后扫描特征
            [peripheral discoverCharacteristics:nil forService:serive];
            //  break;
        }else{
            //如果没有找到
            // [peripheral discoverServices:nil];
        }
    }
    //写入时间服务
    for (CBService *serive in peripheral.services) {
        if ([serive.UUID.UUIDString isEqualToString:@"FFE5"]) {
            //遍历之后找到了自己想要的服务
            //然后扫描特征
            [peripheral discoverCharacteristics:nil forService:serive];
            //  break;
        }else{
            
        }
    }
}
//扫描特征之后的方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    //写入时间
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFE9"]) {
            //拿到外围特征了,可以交互了
           [peripheral writeValue:[NSData data] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    NSLog(@"%@",service.characteristics);
    //扫描之后的特征会自动放在某个数组里面
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFE4"]) {
            //拿到外围特征了,可以交互了
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        }
    }
    
}
//监听成功的方法
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying==0) {
        NSLog(@"设置失败");
    }else{
        NSLog(@"设置成功");
    }
}
//监听特征发生改变触发的方法
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"监听特征发生改变");
}


@end

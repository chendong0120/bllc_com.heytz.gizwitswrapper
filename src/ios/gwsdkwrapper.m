/********* gwsdkwrapper.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <XPGWifiSDK/XPGWifiSDK.h>

@interface gwsdkwrapper : CDVPlugin<XPGWifiDeviceDelegate,XPGWifiSDKDelegate> {

    // Member variables go here.
    
}

- (void)getCurrentSSID:(CDVInvokedUrlCommand*)command;
- (void)setDeviceWifi:(CDVInvokedUrlCommand *)command;

@property (strong,nonatomic) CDVInvokedUrlCommand * commandHolder;

@end

@implementation gwsdkwrapper

@synthesize commandHolder;
NSString * productKey;


-(void)pluginInitialize{    

}

- (void)getCurrentSSID:(CDVInvokedUrlCommand*)command
{

    CDVPluginResult *pluginResult = nil;
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    NSLog(@"ifs:%@",ifs);
    for (NSString *ifnam in ifs) {
         NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
         NSLog(@"dici：%@",[info  allKeys]);
         if (info[@"SSID"]) {
               ssid = info[@"SSID"];
         }
     }

     if(ssid!=nil && [ssid length] > 0){
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ssid];
     } else {
         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
     }
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/*
 *
 */
-(void)setDeviceWifi:(CDVInvokedUrlCommand *)command
{

    [XPGWifiSDK startWithAppID:command.arguments[2]];//@"b40af87e302b4415a374a9c2b1bb4bec"];
                                //3dfd6151942c4ca1a60c8fa70d43960d
    [XPGWifiSDK sharedInstance].delegate = self;

    /**
     * @brief 配置路由的方法
     * @param ssid：需要配置到路由的SSID名
     * @param key：需要配置到路由的密码
     * @param mode：配置方式 SoftAPMode=软AP模式 AirLinkMode=一键配置模式
     * @param softAPSSIDPrefix：SoftAPMode模式下SoftAP的SSID前缀或全名（XPGWifiSDK以此判断手机当前是否连上了SoftAP，AirLinkMode该参数无意义，传nil即可）
     * @param timeout: 配置的超时时间 SDK默认执行的最小超时时间为30秒
     * @see 对应的回调接口：[XPGWifiSDK XPGWifiSDK:didSetDeviceWifi:result:]
     */
    
    NSLog(@"ssid: %@", command.arguments[0]);
    NSLog(@"key: %@", command.arguments[1]);
    
    self.commandHolder = command;
    
    [[XPGWifiSDK sharedInstance] setDeviceWifi:command.arguments[0] key:command.arguments[1] mode:XPGWifiSDKAirLinkMode softAPSSIDPrefix:nil timeout:180];
}


- (void)XPGWifiSDK:(XPGWifiSDK *)wifiSDK didSetDeviceWifi:(XPGWifiDevice *)device result:(int)result{
  
    /**
     * @brief 回调接口，返回设备配置的结果
     * @param device：已配置成功的设备
     * @param result：配置结果 成功 - 0 或 失败 - 1 如果配置失败，device为nil
     * @see 触发函数：[XPGWifiSDK setDeviceWifi:key:mode:]
     */
    
    CDVPluginResult *pluginResult = nil;
    NSDictionary *ret = nil;
    
    
    if (result == 0 ) {
        // successful
        
        ret =
        [NSDictionary dictionaryWithObjectsAndKeys:
         device.did, @"did",
         device.ipAddress, @"ipAddress",
         device.macAddress, @"macAddress",
         device.passcode, @"passcode",
         device.productKey, @"productKey",
         device.productName, @"productName",
         device.remark, @"remark",
         device.ui, @"ui",
         device.isConnected, @"isConnected",
         device.isDisabled, @"isDisabled",
         device.isLAN, @"isLAN",
         device.isOnline, @"isOnline",
         @"",@"error",
         nil];
        
        productKey = device.productKey;
        
        if(device.did && device.did.length == 22 && device.productKey && device.productKey.length == 32)
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:ret];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];
        }
        
    }
    else
    {
        if (productKey && productKey.length == 32) {
           ret =
            [NSDictionary dictionaryWithObjectsAndKeys:
             device.did, @"did",
             device.ipAddress, @"ipAddress",
             device.macAddress, @"macAddress",
             device.passcode, @"passcode",
             device.productKey, @"productKey",
             device.productName, @"productName",
             device.remark, @"remark",
             device.ui, @"ui",
             device.isConnected, @"isConnected",
             device.isDisabled, @"isDisabled",
             device.isLAN, @"isLAN",
             device.isOnline, @"isOnline",
             @"",@"error",
             nil];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:ret];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];
            
        }else
        {
            ret = [NSDictionary dictionaryWithObject:@"timeout" forKey:@"error"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:ret];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:commandHolder.callbackId];
        }
    }
}


@end
